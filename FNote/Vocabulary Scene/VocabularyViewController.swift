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
        /// View vocabulary mode.
        case view(Vocabulary)
        
        /// Create vocabulary mode. Requires a collection for the vocabulary.
        case create(VocabularyCollection)
    }
    
    enum CompletionAction {
        case save
        case cancel
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
        case relations
        case alternatives
        case politeness
        case favorite
        case tag
        case note
    }
}


/// A view controller to view or create vocabulary.
/// - note: This controller creates and manipulates its own context.
///         Its parent context is the context of the vocabulary or collection passed into the initializer.
///         Any data manipulation must be save on the parent context.
class VocabularyViewController: UITableViewController {
    
    weak var coordinator: VocabularyViewer?
    
    private let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    private let vocabulary: Vocabulary
    
    private var sortedTags: [Tag] {
        return vocabulary.tags.sorted(by: { $0.name < $1.name })
    }
    private var estimatedTagCellSizes: [CGSize] = []
    
    /// The vocabulary values before changed. In create mode, this value is always `nil`.
    private var beforeChangeVocabulary: Vocabulary?
    private var beforeChangeContext: NSManagedObjectContext?
    private var saveChangesBarButton: UIBarButtonItem?
    
    var completion: ((CompletionAction) -> Void)?
    
    let indexPathSections: IndexPathSections<Section, Row> = {
        var sections = IndexPathSections<Section, Row>()
        sections.addSection(type: .vocabulary, items: [.native, .translation])
        sections.addSection(type: .relation, items: [.favorite, .relations, .alternatives, .politeness, .tag])
        sections.addSection(type: .note, items: [.note])
        return sections
    }()
    
    
    /// Construct a vocabulary viewer or adder based on the specified mode.
    init(mode: Mode) {
        switch mode {
        case .view(let vocabulary):
            context.parent = vocabulary.managedObjectContext!
            self.vocabulary = context.object(with: vocabulary.objectID) as! Vocabulary
            beforeChangeContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            beforeChangeContext?.parent = context.parent
            beforeChangeVocabulary = beforeChangeContext?.object(with: vocabulary.objectID) as? Vocabulary
        case .create(let collection):
            context.parent = collection.managedObjectContext!
            let collection = context.object(with: collection.objectID) as! VocabularyCollection
            vocabulary = Vocabulary(collection: collection, context: context)
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
    
    
    @objc private func inputTextFieldTextChanged(_ textField: UITextField) {
        guard let input = Row(rawValue: textField.tag) else { return }
        switch input {
        case .native:
            vocabulary.native = textField.text ?? ""
        case .translation:
            vocabulary.translation = textField.text ?? ""
        default:
            fatalError("unknown text field text changed!!!")
        }
        toggleSaveButtonEnableStateIfNeeded()
    }
    
    /// Check if the vocabulary values has changed. In create mode, this always return `true`.
    private func hasChanges() -> Bool  {
        guard let before = beforeChangeVocabulary else { return true } // create mode
        return vocabulary.isFavorited != before.isFavorited
            || vocabulary.politeness != before.politeness
            || vocabulary.translation != before.translation
            || vocabulary.native != before.native
            || vocabulary.note != before.note
            || vocabulary.tags.count != before.tags.count
            || Set(vocabulary.tags.map({ $0.name })).isSubset(of: before.tags.map({ $0.name })) != true
    }
    
    func setPoliteness(_ politeness: Vocabulary.Politeness) {
        vocabulary.politeness = politeness
        toggleSaveButtonEnableStateIfNeeded()
        let indexPath = indexPathSections.firstIndexPath(of: .politeness)!
        let cell = tableView.cellForRow(at: indexPath) as? VocabularySelectionCell
        cell?.reloadCell(detail: politeness.string)
    }
    
    func addTag(_ tag: Tag) {
        guard let tagToAdd = context.object(with: tag.objectID) as? Tag else { return }
        vocabulary.addTag(tagToAdd)
        toggleSaveButtonEnableStateIfNeeded()
        estimatedTagCellSizes.removeAll()
        tableView.reloadData()
    }
    
    func removeTag(name: String) {
        guard let tagToRemove = vocabulary.tags.first(where: { $0.name == name }) else { return }
        vocabulary.removeTag(tagToRemove)
        toggleSaveButtonEnableStateIfNeeded()
        estimatedTagCellSizes.removeAll()
        tableView.reloadData()
    }
    
    private func computeEstimatedTagCellSizes() -> [CGSize] {
        let label = UILabel()
        return sortedTags.map {
            let width = label.estimatedWidth(for: $0.name) + 16
            let size = CGSize(width: width < 45 ? 45 : width, height: 30)
            return size
        }
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
            cell.reloadCell(text: "Politeness", detail: vocabulary.politeness.string, image: .politeness)
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
            #warning("TODO: add tag cell")
            let cell = tableView.dequeueRegisteredCell(VocabularyTagCell.self, for: indexPath)
            cell.reload(with: vocabulary, dataSourceDelegate: self)
            cell.collectionViewTappedHandler = { [weak self] in
                guard let self = self else { return }
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                self.coordinator?.selectTags(for: self, current: self.sortedTags)
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
            #warning("TODO: add tag cell")
            view.endEditing(true)
            coordinator?.selectTags(for: self, current: sortedTags)
        default:
            #warning("add handler relations and alternatives")
            tableView.deselectRow(at: indexPath, animated: true)
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
        cell.reload(with: sortedTags[indexPath.row])
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
    
    @objc private func cancelAction() {
        completion?(.cancel)
    }
    
    @objc func saveChanges() {
        vocabulary.native = vocabulary.native.trimmingCharacters(in: .whitespaces)
        vocabulary.translation = vocabulary.translation.trimmingCharacters(in: .whitespaces)
        vocabulary.note = vocabulary.note.trimmingCharacters(in: .whitespacesAndNewlines)
        view.endEditing(true)
        
        if vocabulary.native.isEmpty {
            animateTextFieldCelldInvalidInput(.native)
            return
        }
        if vocabulary.translation.isEmpty {
            animateTextFieldCelldInvalidInput(.translation)
            return
        }
        
        if hasChanges() {
            context.quickSave()
            completion?(.save)
        } else {
            completion?(.cancel)
        }
    }
}


extension VocabularyViewController {
    
    private func animateTextFieldCelldInvalidInput(_ input: VocabularyViewController.Row) {
        guard input == .native || input == .translation else { return }
        guard let indexPath = indexPathSections.firstIndexPath(of: input) else { return }
        let hapticFeedback = UINotificationFeedbackGenerator()
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.contentView.shakeHorizontally()
            hapticFeedback.notificationOccurred(.error)
        } else {
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                let cell = self.tableView.cellForRow(at: indexPath)
                cell?.contentView.shakeHorizontally()
                hapticFeedback.notificationOccurred(.error)
            }
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
