//
//  VocabularyViewController.swift
//  FNote
//
//  Created by Dara Beng on 1/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit
import CoreData


extension VocabularyViewController {
    
    /// View controlelr mode.
    enum Mode {
        /// View vocabulary.
        case view(Vocabulary)
        
        /// Add vocabulary. Requires a collection for the vocabulary.
        case add(_ collection: VocabularyCollection)
    }
    
    /// Controller's table view section type.
    enum InputSection: Int {
        case vocabulary
        case relation
        case note
    }
    
    /// Controller's table view row type in section.
    enum Input: Int {
        case native
        case translation
        case relations
        case alternatives
        case favorite
        case politeness
        case note
    }
}


class VocabularyViewController: UITableViewController {
    
    private let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    private let vocabulary: Vocabulary
    private let mode: Mode
    
    private var beforeEditContext: NSManagedObjectContext?
    private var beforeEditVocabulary: Vocabulary?
    private var saveChangesBarButton: UIBarButtonItem?
    
    var cancelActionHandler: (() -> Void)?
    var saveChangesHandler: ((Vocabulary)->Void)?
    var addVocabularyHandler: ((Vocabulary) -> Void)?
    
    let inputList: IndexPathList<InputSection, Input> = {
        var list = IndexPathList<InputSection, Input>()
        list.addElement(.init(section: .vocabulary, items: [.native, .translation]))
        list.addElement(.init(section: .relation, items: [.relations, .alternatives, .politeness, .favorite]))
        list.addElement(.init(section: .note, items: [.note]))
        return list
    }()
    
    weak var nativeCell: VocabularyTextFieldCell?
    weak var translationCell: VocabularyTextFieldCell?
    weak var noteCell: VocabularyNoteCell?
    weak var politenessCell: VocabularySelectionCell?
    
    /// Construct a vocabulary viewer
    /// - parameters:
    ///   - vocabulary: The vocabulary to view.
    ///   - collection: The collection of the vocabulary.
    ///   - mode: The controller mode.
    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .view(let vocabulary):
            let vocabularyID = vocabulary.objectID
            let parentContext = vocabulary.managedObjectContext!
            context.parent = parentContext
            self.vocabulary = context.object(with: vocabularyID) as! Vocabulary
            
            beforeEditContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            beforeEditContext?.parent = parentContext
            beforeEditVocabulary = beforeEditContext?.object(with: vocabularyID) as? Vocabulary
       
        case .add(let collection):
            context.parent = collection.managedObjectContext!
            let collection = context.object(with: collection.objectID) as! VocabularyCollection
            vocabulary = Vocabulary(context: context)
            vocabulary.setCollection(collection)
        }
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        setupNavItems()
    }
}


extension VocabularyViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return inputList.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inputList[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch inputList[section].section {
        case .vocabulary: return "NATIVE AND TRANSLATION"
        case .relation: return "RELATIONS AND ALTERNATIVES"
        case .note: return "NOTE"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch inputList[indexPath.section].section {
        case .vocabulary: return 70
        case .relation: return 44
        case .note: return 200
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let input = inputList[indexPath.section].items[indexPath.row]
        switch input {
        case .native:
            let cell = tableView.dequeueRegisteredCell(VocabularyTextFieldCell.self, for: indexPath)
            cell.reloadCell(text: vocabulary.native, placeholder: "Native")
            cell.textField.tag = input.rawValue
            cell.textField.delegate = self
            nativeCell = cell
            return cell
        case .translation:
            let cell = tableView.dequeueRegisteredCell(VocabularyTextFieldCell.self, for: indexPath)
            cell.reloadCell(text: vocabulary.translation, placeholder: "Translation")
            cell.textField.tag = input.rawValue
            cell.textField.delegate = self
            translationCell = cell
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
            cell.showSwitcher(on: vocabulary.isFavorited)
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
        let input = inputList[indexPath.section].items[indexPath.row]
        switch input {
        case .native, .translation:
            let cell = tableView.cellForRow(at: indexPath) as! VocabularyTextFieldCell
            guard !cell.textField.isFirstResponder else { return }
            cell.textField.becomeFirstResponder()
        case .politeness:
            let cell = tableView.cellForRow(at: indexPath) as! VocabularySelectionCell
            politenessCell = cell
            let options = Vocabulary.Politeness.allCases.map({ $0.string })
            let optionVC = OptionTableViewController(options: options, selectedOptions: [vocabulary.politeness])
            optionVC.navigationItem.title = "Politeness"
            optionVC.selectOptionHandler = { [weak self] (selectedIndex) in
                guard let self = self else { return }
                self.vocabulary.politeness = options[selectedIndex]
                self.politenessCell?.reloadCell(detail: self.vocabulary.politeness)
                self.politenessCell = nil
                self.navigationController?.popViewController(animated: true)
                self.toggleSaveButtonEnableStateIfNeeded()
            }
            view.endEditing(true)
            navigationController?.pushViewController(optionVC, animated: true)
        default:
            view.endEditing(true)
        }
    }
}


extension VocabularyViewController: VocabularySelectionCellDelegate {
    
    func vocabularySelectionCell(_ cell: VocabularySelectionCell, didToggleSwitcher switcher: UISwitch) {
        vocabulary.isFavorited = switcher.isOn
        toggleSaveButtonEnableStateIfNeeded()
    }
}


extension VocabularyViewController: UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        vocabulary.note = textView.text
        noteCell?.hidePlaceholderIfNeeded()
        toggleSaveButtonEnableStateIfNeeded()
    }
}


extension VocabularyViewController {
    
    private func setupController() {
        view.backgroundColor = .offWhiteBackground
        tableView.registerCell(VocabularyTextFieldCell.self)
        tableView.registerCell(VocabularySelectionCell.self)
        tableView.registerCell(VocabularyNoteCell.self)
        setupNotificationHandlers()
    }
    
    private func setupNavItems() {
        switch mode {
        case .view:
            navigationItem.leftBarButtonItem = nil
            saveChangesBarButton = .init(barButtonSystemItem: .save, target: self, action: #selector(saveChanges))
        case .add:
            let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
            let add = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addVocabulary))
            navigationItem.leftBarButtonItem = cancel
            navigationItem.rightBarButtonItem = add
        }
    }
    
    private func setupNotificationHandlers() {
        let name = UITextField.textDidChangeNotification
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextFieldCellTextChanged), name: name, object: nil)
    }
    
    @objc private func handleTextFieldCellTextChanged(_ notification: Notification) {
        guard let textField = notification.object as? UITextField else { return }
        guard let input = VocabularyViewController.Input(rawValue: textField.tag) else { return }
        switch input {
        case .native:
            vocabulary.native = textField.text ?? ""
        case .translation:
            vocabulary.translation = textField.text ?? ""
        default:
            fatalError("handling unknown textfield")
        }
        toggleSaveButtonEnableStateIfNeeded()
    }
    
    @objc private func cancelAction() {
        cancelActionHandler?()
    }
    
    @objc private func saveChanges() {
        saveChangesHandler?(vocabulary)
    }
    
    @objc private func addVocabulary() {
        view.endEditing(true)
        if vocabulary.native.trimmingCharacters(in: .whitespaces).isEmpty {
            animateTextFieldCelldInvalidInput(.native)
            return
        }
        if vocabulary.translation.trimmingCharacters(in: .whitespaces).isEmpty {
            animateTextFieldCelldInvalidInput(.translation)
            return
        }
        addVocabularyHandler?(vocabulary)
    }
}


extension VocabularyViewController {
    
    private func animateTextFieldCelldInvalidInput(_ input: VocabularyViewController.Input) {
        guard input == .native || input == .translation else { return }
        guard let indexPath = inputList.indexPath(for: input) else { return }
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.contentView.shakeHorizontally()
        } else {
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                let cell = self.tableView.cellForRow(at: indexPath)
                cell?.contentView.shakeHorizontally(duration: 0.4)
            }
        }
    }
    
    /// Check if vocabulary has different value. This compare excludes `relations` and `alternatives`.
    private func toggleSaveButtonEnableStateIfNeeded() {
        guard let before = beforeEditVocabulary else { return }
        let after = vocabulary
        
        let hasChanges = before.native != after.native
            || before.translation != after.translation
            || before.politeness != after.politeness
            || before.isFavorited != after.isFavorited
            || before.note != after.note
        
        if !hasChanges {
            navigationItem.setRightBarButton(nil, animated: true)
        } else if hasChanges, navigationItem.rightBarButtonItem == nil {
            navigationItem.setRightBarButton(saveChangesBarButton, animated: true)
        }
    }
}
