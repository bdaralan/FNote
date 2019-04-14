//
//  VocabularyViewController.swift
//  FNote
//
//  Created by Dara Beng on 1/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit
import CoreData


/// A view controller to view or create vocabulary.
/// - note: This controller creates and manipulates its own context.
///         Its parent context is the context of the vocabulary or collection passed into the initializer.
///         Any data manipulation must be saved to the parent context to persist changes, see `saveChanges()`.
class VocabularyViewController: UITableViewController {
    
    weak var coordinator: VocabularyViewable?
    
    /// The parent context that any changes should save to.
    let parentContext: NSManagedObjectContext
    
    /// The context that controller is working on.
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    /// The vocabulary to work on. This vocabulary is in the controller context.
    private let vocabulary: Vocabulary
    
    private var user: User {
        return vocabulary.collection.user
    }
    
    var vocabularyObjectID: NSManagedObjectID {
        return vocabulary.objectID
    }
    
    var existingTags: [String] {
        return user.tags.map({ $0.name }).sorted()
    }
    
    var currentTags: [String] {
        return vocabulary.tags.map({ $0.name }).sorted()
    }
    
    private var estimatedTagCellSizes: [CGSize] = []
    
    /// The vocabulary values before changed. In create mode, this value is always `nil`.
    private var beforeChangeVocabulary: Vocabulary?
    private var saveChangesBarButton: UIBarButtonItem?
    
    /// The completion block that gets called after `saveChanges()`.
    var saveCompletion: ((SaveResult) -> Void)?
    
    let indexPathSections: IndexPathSections<Section, Row> = {
        var sections = IndexPathSections<Section, Row>()
        sections.addSection(type: .vocabulary, items: [.native, .translation])
        sections.addSection(type: .relation, items: [.favorite, .politeness, .connection, .tag])
        sections.addSection(type: .note, items: [.note])
        return sections
    }()
    
    
    /// Construct a vocabulary viewer or adder based on the specified mode.
    /// - note: The controller will create a new context to work on so that changes will not affect the original context until save.
    ///         If need to pass around the vocabulary, make sure to use an appropriate context.
    ///         Access the `vocabulary` from the controller for the same context.
    init(mode: Mode) {
        switch mode {
        case .view(let vocabulary):
            parentContext = vocabulary.managedObjectContext!
            context.parent = parentContext
            self.vocabulary = context.object(with: vocabulary.objectID) as! Vocabulary
            beforeChangeVocabulary = vocabulary
        
        case .create(let collection):
            parentContext = collection.managedObjectContext!
            context.parent = parentContext
            let collection = context.object(with: collection.objectID) as! VocabularyCollection
            vocabulary = Vocabulary(collection: collection)
        }
        
        super.init(style: .grouped)
        setupNavItems(mode: mode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }
    
    func setPoliteness(_ politeness: Vocabulary.Politeness) {
        vocabulary.politeness = politeness
        toggleSaveButtonEnableStateIfNeeded()
        let indexPath = indexPathSections.firstIndexPath(of: .politeness)!
        let cell = tableView.cellForRow(at: indexPath) as? VocabularySelectionCell
        cell?.reloadCell(detail: politeness.displayText)
    }
    
    /// Add tag to the vocabulary.
    /// - parameters:
    ///   - name: The name of the tag to be added.
    ///   - create: Pass `true` to create a new tag if it does not exist.
    func addTag(name: String, create: Bool) {
        guard currentTags.contains(name) == false else { return }
        if vocabulary.addTag(existingName: name) == nil, create {
            vocabulary.addTag(newName: name, colorHex: nil)
        }
        toggleSaveButtonEnableStateIfNeeded()
        estimatedTagCellSizes.removeAll()
        tableView.reloadData()
    }
    
    /// Remove tag from the vocabulary.
    /// - parameters:
    ///   - name: The name of the tag to be removed.
    ///   - delete: Pass `true` to remove and delete the tag.
    func removeTag(name: String, delete: Bool) {
        vocabulary.removeTag(name: name)
        toggleSaveButtonEnableStateIfNeeded()
        estimatedTagCellSizes.removeAll()
        tableView.reloadData()
        guard delete, let tagToDelete = user.tags.first(where: { $0.name == name }) else { return }
        context.delete(tagToDelete)
    }
    
    func renameTag(current: String, newName: String) {
        guard let tagToRename = user.tags.first(where: { $0.name == current }) else { return }
        tagToRename.rename(newName)
        toggleSaveButtonEnableStateIfNeeded()
        estimatedTagCellSizes.removeAll()
        tableView.reloadData()
    }
    
    private func computeEstimatedTagCellSizes() -> [CGSize] {
        let label = UILabel()
        return currentTags.map {
            let width = label.estimatedWidth(for: $0) + 16
            let size = CGSize(width: width < 45 ? 45 : width, height: 30)
            return size
        }
    }
    
    /// Check if the vocabulary values has changed. In create mode, this always return `true`.
    private func hasChanges() -> Bool  {
        guard let before = beforeChangeVocabulary else { return true } // create mode
        return Vocabulary.hasChanges(before: before, after: vocabulary)
    }
    
    /// Save changes all changes in its own context.
    @objc func saveChanges() {
        view.endEditing(true)
        
        vocabulary.native = vocabulary.native.trimmingCharacters(in: .whitespaces)
        vocabulary.translation = vocabulary.translation.trimmingCharacters(in: .whitespaces)
        vocabulary.note = vocabulary.note.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if vocabulary.native.isEmpty || vocabulary.translation.isEmpty {
            animateTextFieldCelldInvalidInput(navtive: vocabulary.native.isEmpty, translation: vocabulary.translation.isEmpty)
            return
        }
        
        if hasChanges() {
            context.quickSave()
            parentContext.quickSave()
            saveCompletion?(.saved)
        } else {
            saveCompletion?(.ignored)
        }
    }
    
    @objc private func cancelAction() {
        saveCompletion?(.ignored)
    }
    
    @objc private func inputTextFieldTextChanged(_ textField: UITextField) {
        guard let input = Row(rawValue: textField.tag) else { return }
        switch input {
        case .native:
            vocabulary.native = textField.text ?? ""
        case .translation:
            vocabulary.translation = textField.text ?? ""
        case .connection, .politeness, .favorite, .tag, .note:
            fatalError("unknown text field text changed!!!")
        }
        toggleSaveButtonEnableStateIfNeeded()
    }
}


extension VocabularyViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return indexPathSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return indexPathSections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch indexPathSections[section].type {
        case .vocabulary: return "NATIVE AND TRANSLATION"
        case .relation: return "RELATIONS AND ALTERNATIVES"
        case .note: return "NOTE"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPathSections[indexPath.section].type {
        case .vocabulary: return 70
        case .relation: return 44
        case .note: return 200
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let input = indexPathSections[indexPath.section].items[indexPath.row]
        switch input {
        case .native:
            let cell = tableView.dequeueRegisteredCell(VocabularyTextFieldCell.self, for: indexPath)
            cell.reloadCell(text: vocabulary.native, placeholder: "Native")
            cell.textField.tag = input.rawValue
            cell.textField.addTarget(self, action: #selector(inputTextFieldTextChanged), for: .editingChanged)
            return cell
        case .translation:
            let cell = tableView.dequeueRegisteredCell(VocabularyTextFieldCell.self, for: indexPath)
            cell.reloadCell(text: vocabulary.translation, placeholder: "Translation")
            cell.textField.tag = input.rawValue
            cell.textField.addTarget(self, action: #selector(inputTextFieldTextChanged), for: .editingChanged)
            return cell
        case .connection:
            let cell = tableView.dequeueRegisteredCell(VocabularySelectionCell.self, for: indexPath)
            cell.reloadCell(text: "Connections", detail: "\(vocabulary.connections.count)", image: .connection)
            cell.accessoryType = .disclosureIndicator
            return cell
        case .politeness:
            let cell = tableView.dequeueRegisteredCell(VocabularySelectionCell.self, for: indexPath)
            cell.reloadCell(text: "Politeness", detail: vocabulary.politeness.displayText, image: .politeness)
            cell.accessoryType = .disclosureIndicator
            return cell
        case .favorite:
            let cell = tableView.dequeueRegisteredCell(VocabularySelectionCell.self, for: indexPath)
            cell.reloadCell(text: "Favorite", detail: "", image: .favorite)
            cell.showSwitcher(on: vocabulary.isFavorited)
            cell.switcherValueChangedHandler = { [weak self] (isOn) in
                self?.vocabulary.isFavorited = isOn
                self?.toggleSaveButtonEnableStateIfNeeded()
            }
            return cell
        case .tag:
            let cell = tableView.dequeueRegisteredCell(VocabularyTagCell.self, for: indexPath)
            cell.reload(with: vocabulary, dataSourceDelegate: self)
            cell.collectionViewTappedHandler = { [weak self] in
                guard let self = self else { return }
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                self.coordinator?.selectTags(for: self, current: self.currentTags, existingTags: self.existingTags)
            }
            cell.accessoryType = .disclosureIndicator
            return cell
        case .note:
            let cell = tableView.dequeueRegisteredCell(VocabularyNoteCell.self, for: indexPath)
            cell.reloadCell(note: vocabulary.note)
            cell.noteChangedHandler = { [weak self] (note) in
                self?.vocabulary.note = note
                self?.toggleSaveButtonEnableStateIfNeeded()
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let input = indexPathSections[indexPath.section].items[indexPath.row]
        switch input {
        case .native, .translation:
            let cell = tableView.cellForRow(at: indexPath) as! VocabularyTextFieldCell
            guard !cell.textField.isFirstResponder else { return }
            cell.textField.becomeFirstResponder()
        case .politeness:
            view.endEditing(true)
            coordinator?.selectPoliteness(for: self, current: vocabulary.politeness)
        case .tag:
            view.endEditing(true)
            coordinator?.selectTags(for: self, current: currentTags, existingTags: existingTags)
        case .connection:
            view.endEditing(true)
            coordinator?.selectVocabularyConnection(for: self)
        case .favorite, .note: ()
        }
    }
}


extension VocabularyViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vocabulary.tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if estimatedTagCellSizes.isEmpty {
            estimatedTagCellSizes = computeEstimatedTagCellSizes()
        }
        return estimatedTagCellSizes[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueRegisteredCell(VocabularyCollectionViewTagCell.self, for: indexPath)
        cell.reload(tagName: currentTags[indexPath.row])
        return cell
    }
}


extension VocabularyViewController {
    
    private func setupController() {
        view.backgroundColor = .offWhiteBackground
        tableView.registerCell(VocabularyTextFieldCell.self)
        tableView.registerCell(VocabularySelectionCell.self)
        tableView.registerCell(VocabularyNoteCell.self)
        tableView.registerCell(VocabularyTagCell.self)
    }
    
    private func setupNavItems(mode: Mode) {
        switch mode {
        case .view:
            navigationItem.leftBarButtonItem = nil
            saveChangesBarButton = .init(title: "Save", style: .done, target: self, action: #selector(saveChanges))
        case .create:
            let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
            let add = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(saveChanges))
            navigationItem.leftBarButtonItem = cancel
            navigationItem.rightBarButtonItem = add
        }
        navigationItem.largeTitleDisplayMode = .never
    }
}


extension VocabularyViewController {
    
    private func animateTextFieldCelldInvalidInput(navtive: Bool, translation: Bool) {
        let nativeIndexPath = indexPathSections.firstIndexPath(of: .native)!
        let translationIndexPath = indexPathSections.firstIndexPath(of: .translation)!
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let self = self else { return }
            self.tableView.scrollToRow(at: nativeIndexPath, at: .top, animated: false)
        }) { [weak self] (finished) in
            guard let self = self else { return }
            let hapticFeedback = UINotificationFeedbackGenerator()
            let nativeCell = self.tableView.cellForRow(at: nativeIndexPath) as? VocabularyTextFieldCell
            let translationCell = self.tableView.cellForRow(at: translationIndexPath) as? VocabularyTextFieldCell
            nativeCell?.markError(navtive, animated: navtive)
            translationCell?.markError(translation, animated: translation)
            hapticFeedback.notificationOccurred(.error)
        }
    }
    
    /// Check if vocabulary has different value then decide to show or hide the save button.
    /// This does not compare `relations` and `alternatives`.
    /// - note: This method is async.
    private func toggleSaveButtonEnableStateIfNeeded() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch self.hasChanges() {
            case false where self.navigationItem.rightBarButtonItem != nil:
                self.navigationItem.setRightBarButton(nil, animated: true)
            case true where self.navigationItem.rightBarButtonItem == nil:
                self.navigationItem.setRightBarButton(self.saveChangesBarButton, animated: true)
            default: ()
            }
        }
    }
}


extension VocabularyViewController {
    
    /// View controller mode.
    enum Mode {
        /// View vocabulary mode.
        case view(Vocabulary)
        
        /// Create vocabulary mode. Requires a collection for the vocabulary.
        case create(VocabularyCollection)
    }
    
    enum SaveResult {
        case saved
        case ignored
    }
    
    /// Controller's table view section type.
    enum Section: Int {
        case vocabulary
        case relation
        case note
    }
    
    /// Controller's table view row type in section.
    enum Row: Int {
        case native
        case translation
        case connection
        case politeness
        case favorite
        case tag
        case note
    }
}
