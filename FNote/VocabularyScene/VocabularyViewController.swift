//
//  VocabularyViewController.swift
//  FNote
//
//  Created by Dara Beng on 1/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit
import CoreData


class VocabularyViewController: UITableViewController {
    
    private(set) var vocabulary: Vocabulary
    private(set) var collection: VocabularyCollection
    
    private lazy var vocabularyBeforeEdit = VocabularyModel()

    private var mode: Mode
    
    var isTextEditingAllowed: Bool {
        return mode == .edit || mode == .add
    }
    
    var cancelActionHandler: (() -> Void)?
    var saveChangesHandler: ((Vocabulary) -> Void)?
    var addVocabularyHandler: ((Vocabulary, VocabularyCollection) -> Void)?
    
    let inputList: IndexPathList<InputSection, Input> = {
        var list = IndexPathList<InputSection, Input>()
        list.addElement(.init(section: .vocabulary, items: [.native, .translation]))
        list.addElement(.init(section: .relation, items: [.relations, .alternatives, .politeness, .favorite]))
        list.addElement(.init(section: .note, items: [.note]))
        return list
    }()
    
    let politenessOptions: [Vocabulary.Politeness] = Vocabulary.Politeness.allCases
    
    weak var nativeCell: VocabularyTextFieldCell?
    weak var translationCell: VocabularyTextFieldCell?
    weak var noteCell: VocabularyNoteCell?
    weak var politenessCell: VocabularySelectionCell?
    
    /// Construct a vocabulary viewer or creater.
    /// - parameters:
    ///   - vocabulary: The vocabulary to view or pass `nil` to create a vocabulary.
    ///   - collection: The collection of the vocabulary.
    init(vocabulary: Vocabulary?, collection: VocabularyCollection) {
        self.mode = vocabulary == nil ? .add : .view
        self.vocabulary = vocabulary ?? Vocabulary(context: collection.managedObjectContext!)
        self.collection = collection
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }
    
    @objc private func updateVocabularyNavtiveTranslation(_ sender: UITextField) {
        sender.tintColor = nil
        guard let input = VocabularyViewController.Input(rawValue: sender.tag) else { return }
        switch input {
        case .native: vocabulary.native = sender.text ?? ""
        case .translation: vocabulary.translation = sender.text ?? ""
        default: fatalError("unknown sender text field!!!")
        }
        print("same values: \(vocabularyBeforeEdit.isValuesEqualTo(vocabulary))")
    }
    
    @objc private func handleTextFieldTextChanged(_ notification: Notification) {
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
        print(vocabulary)
    }
    
    /// Validate the required fields.
    /// - returns: `false` and play appropriate animation if there any invalid inputs. Otherwise, `true`
    private func validateInputFields() -> Bool {
        view.endEditing(true)
        
        if vocabulary.native.trimmingCharacters(in: .whitespaces).isEmpty {
            animateTextFielCelldInvalidInput(input: .native)
            return false
        }
        
        if vocabulary.translation.trimmingCharacters(in: .whitespaces).isEmpty {
            animateTextFielCelldInvalidInput(input: .translation)
            return false
        }
        
        return true
    }
    
    private func animateTextFielCelldInvalidInput(input: VocabularyViewController.Input) {
        guard input == .native || input == .translation else { return }
        guard let nativeIndex = inputList.indexPath(for: input) else { return }
        if let cell = tableView.cellForRow(at: nativeIndex) {
            cell.contentView.shakeHorizontally()
        } else {
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }
                self.tableView.scrollToRow(at: nativeIndex, at: .top, animated: false)
                let cell = self.tableView.cellForRow(at: nativeIndex) as! VocabularyTextFieldCell
                cell.contentView.shakeHorizontally(duration: 0.4)
            }
        }
    }
    
    func setMode(_ mode: Mode) {
        self.mode = mode
        nativeCell?.isQuickCopyEnabled = !isTextEditingAllowed
        translationCell?.isQuickCopyEnabled = !isTextEditingAllowed
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
            cell.isQuickCopyEnabled = !isTextEditingAllowed
            nativeCell = cell
            return cell
        case .translation:
            let cell = tableView.dequeueRegisteredCell(VocabularyTextFieldCell.self, for: indexPath)
            cell.reloadCell(text: vocabulary.translation, placeholder: "Translation")
            cell.textField.tag = input.rawValue
            cell.textField.delegate = self
            cell.isQuickCopyEnabled = !isTextEditingAllowed
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
            let options = politenessOptions.map({ $0.string })
            let optionVC = OptionTableViewController(options: options, selectedOptions: [vocabulary.politeness])
            optionVC.navigationItem.title = "Politeness"
            optionVC.selectOptionHandler = { [weak self] (index) in
                guard let self = self else { return }
                self.vocabulary.politeness = options[index]
                self.vocabulary.managedObjectContext?.quickSave()
                self.politenessCell?.reloadCell(detail: self.vocabulary.politeness)
                self.politenessCell = nil
                self.navigationController?.popViewController(animated: true)
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
        vocabulary.managedObjectContext?.quickSave()
    }
}


extension VocabularyViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return isTextEditingAllowed
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}

extension VocabularyViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return isTextEditingAllowed
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
        setupNavItems()
        setupNotificationHandlers()
    }
    
    private func setupNotificationHandlers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextFieldTextChanged(_:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    private func setupNavItems() {
        switch mode {
        case .view:
            let edit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editVocaulary))
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = edit
        case .edit:
            let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveChanges))
            navigationItem.leftBarButtonItem = cancel
            navigationItem.rightBarButtonItem = done
            vocabularyBeforeEdit.setValues(with: vocabulary)
        case .add:
            let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
            let add = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addVocabulary))
            navigationItem.leftBarButtonItem = cancel
            navigationItem.rightBarButtonItem = add
        }
    }
    
    @objc private func editVocaulary() {
        setMode(.edit)
    }
    
    @objc private func saveChanges() {
        guard validateInputFields() else { return }
        saveChangesHandler?(vocabulary)
    }
    
    @objc private func addVocabulary() {
        guard validateInputFields() else { return }
        addVocabularyHandler?(vocabulary, collection)
    }
    
    @objc private func cancelAction() {
        cancelActionHandler?()
    }
}
