//
//  VocabularyViewController.swift
//  FNote
//
//  Created by Dara Beng on 1/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


protocol VocabularyViewControllerDelegate: class {
    
    func vocabularyViewController(_ viewController: VocabularyViewController, didRequestCancel vocabulary: Vocabulary)
    
    func vocabularyViewController(_ viewController: VocabularyViewController, didRequestSave vocabulary: Vocabulary)
}


class VocabularyViewController: UITableViewController {
    
    weak var delegate: VocabularyViewControllerDelegate?
    
    private let isCreatingVocabulary: Bool
    private let vocabulary: Vocabulary
    
    let indexPathList: IndexPathList<InputSection, Input> = {
        var list = IndexPathList<InputSection, Input>()
        list.addElement(.init(section: .vocabulary, items: [.native, .translation]))
        list.addElement(.init(section: .relation, items: [.relations, .alternatives, .politeness, .favorite]))
        list.addElement(.init(section: .note, items: [.note]))
        return list
    }()
    
    let politenessOptions: [Vocabulary.Politeness] = Vocabulary.Politeness.allCases
    
    weak var noteCell: VocabularyNoteCell?
    weak var politenessCell: VocabularySelectionCell?
    
    /// Constructor for viewing a vocabulary.
    /// - parameter vocabulary: The vocabulary to be viewed.
    init(vocabulary: Vocabulary) {
        self.isCreatingVocabulary = false
        self.vocabulary = vocabulary
        super.init(style: .grouped)
    }
    
    /// Constructor for creating a new vocabulary.
    /// - parameter collection: The collection for the new vocabulary to be added in.
    init(collection: VocabularyCollection) {
        self.isCreatingVocabulary = true
        let newVocabulary = Vocabulary(context: collection.managedObjectContext!)
        newVocabulary.collection = collection
        self.vocabulary = newVocabulary
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }
    
    @objc private func requestSaveVocabulary() {
        delegate?.vocabularyViewController(self, didRequestSave: vocabulary)
    }
    
    @objc private func requestCancelVocabulary() {
        delegate?.vocabularyViewController(self, didRequestCancel: vocabulary)
    }
    
    @objc private func updateVocabularyNavtiveTranslation(_ sender: UITextField) {
        guard let input = VocabularyViewController.Input(rawValue: sender.tag) else { return }
        switch input {
        case .native: vocabulary.native = sender.text ?? ""
        case .translation: vocabulary.translation = sender.text ?? ""
        default: fatalError("unknown sender text field!!!")
        }
    }
}


extension VocabularyViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return indexPathList.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return indexPathList[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch indexPathList[section].section {
        case .vocabulary: return "NATIVE AND TRANSLATION"
        case .relation: return "RELATIONS AND ALTERNATIVES"
        case .note: return "NOTE"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPathList[indexPath.section].section {
        case .vocabulary: return 70
        case .relation: return 44
        case .note: return 200
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let input = indexPathList[indexPath.section].items[indexPath.row]
        switch input {
        case .native:
            let cell = tableView.dequeueRegisteredCell(VocabularyTextFieldCell.self, for: indexPath)
            cell.reloadCell(text: vocabulary.native, placeholder: "Native")
            cell.textField.tag = input.rawValue
            cell.textField.delegate = self
            cell.textField.addTarget(self, action: #selector(updateVocabularyNavtiveTranslation(_:)), for: .allEditingEvents)
            return cell
        case .translation:
            let cell = tableView.dequeueRegisteredCell(VocabularyTextFieldCell.self, for: indexPath)
            cell.reloadCell(text: vocabulary.translation, placeholder: "Translation")
            cell.textField.tag = input.rawValue
            cell.textField.delegate = self
            cell.textField.addTarget(self, action: #selector(updateVocabularyNavtiveTranslation(_:)), for: .allEditingEvents)
            return cell
        case .relations:
            let cell = tableView.dequeueRegisteredCell(VocabularySelectionCell.self, for: indexPath)
            cell.reloadCell(text: "Related Vocabularies", detail: "\(vocabulary.relations.count)", image: .relation)
            cell.accessoryType = .disclosureIndicator
            return cell
        case .alternatives:
            let cell = tableView.dequeueRegisteredCell(VocabularySelectionCell.self, for: indexPath)
            cell.reloadCell(text: "Alternative Vocabularies", detail: "\(vocabulary.alternatives.count)", image: .alternative)
            cell.accessoryType = .disclosureIndicator
            return cell
        case .politeness:
            let cell = tableView.dequeueRegisteredCell(VocabularySelectionCell.self, for: indexPath)
            cell.reloadCell(text: "Politeness", detail: vocabulary.politeness, image: .politeness)
            cell.accessoryType = .disclosureIndicator
            return cell
        case .favorite:
            let cell = tableView.dequeueRegisteredCell(VocabularySelectionCell.self, for: indexPath)
            cell.reloadCell(text: "Favorite", detail: "", image: .favorite)
            cell.showSwitcher(on: true)
            cell.delegate = self
            return cell
        case .note:
            let cell = tableView.dequeueRegisteredCell(VocabularyNoteCell.self, for: indexPath)
            cell.reloadCell(text: "", placeholder: ". . .")
            cell.textView.delegate = self
            noteCell = cell
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let input = indexPathList[indexPath.section].items[indexPath.row]
        switch input {
        case .native, .translation:
            let cell = tableView.cellForRow(at: indexPath) as! VocabularyTextFieldCell
            guard !cell.textField.isFirstResponder else { return }
            cell.textField.becomeFirstResponder()
        case .politeness:
            let cell = tableView.cellForRow(at: indexPath) as! VocabularySelectionCell
            politenessCell = cell
            let optionVC = OptionTableViewController()
            optionVC.dataSourceDelegate = self
            optionVC.navigationItem.title = "Politeness"
            view.endEditing(true)
            navigationController?.pushViewController(optionVC, animated: true)
        default:
            view.endEditing(true)
        }
    }
}


extension VocabularyViewController: OptionTableViewControllerDataSoureDelegate {
    
    func numberOfOptions(in controller: OptionTableViewController) -> Int {
        return politenessOptions.count
    }
    
    func optionTableViewController(_ controller: OptionTableViewController, optionAtIndex index: Int) -> String {
        return politenessOptions[index].rawValue
    }
    
    func optionTableViewController(_ controller: OptionTableViewController, showsCheckmarkAt index: Int) -> Bool {
        return politenessOptions[index].rawValue == vocabulary.politeness
    }
    
    func optionTableViewController(_ controller: OptionTableViewController, didSelectOptionAtIndex index: Int) {
        print("optionTableViewController didSelectOptionAtIndex: \(index)")
        vocabulary.politeness = politenessOptions[index].rawValue
        politenessCell?.reloadCell(detail: vocabulary.politeness)
        politenessCell = nil
        navigationController?.popViewController(animated: true)
    }
}


extension VocabularyViewController: VocabularySelectionCellDelegate {
    
    func vocabularySelectionCell(_ cell: VocabularySelectionCell, didToggleSwitcher switcher: UISwitch) {
        print("vocabularySelectionCell didToggleSwitcher: \(switcher.isOn)")
        vocabulary.isFavorited = switcher.isOn
    }
}


extension VocabularyViewController: UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        vocabulary.note = textView.text
        noteCell?.hidePlaceholderIfNeeded()
    }
}


extension VocabularyViewController {
    
    private func setupController() {
        view.backgroundColor = .offWhiteBackground
        tableView.registerCell(VocabularyTextFieldCell.self)
        tableView.registerCell(VocabularySelectionCell.self)
        tableView.registerCell(VocabularyNoteCell.self)
        setupNavItem()
    }
    
    private func setupNavItem() {
        if isCreatingVocabulary {
            let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(requestCancelVocabulary))
            let add = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(requestSaveVocabulary))
            navigationItem.leftBarButtonItem = cancel
            navigationItem.rightBarButtonItem = add
        } else {
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(requestSaveVocabulary))
            navigationItem.rightBarButtonItem = done
        }
    }
}
