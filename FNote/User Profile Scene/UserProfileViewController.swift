//
//  UserProfileViewController.swift
//  FNote
//
//  Created by Dara Beng on 3/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit
import CoreData


class UserProfileViewController: UITableViewController {
    
    let user: User
    let context: NSManagedObjectContext
    let fetchController: NSFetchedResultsController<VocabularyCollection>
    
    private(set) var selectedCollection: VocabularyCollection?
    
    var doneTappedHandler: (() -> Void)?
    
    private var collections: [VocabularyCollection] {
        return fetchController.fetchedObjects ?? []
    }
    
    var addNewCollectionIndexPath: IndexPath {
        return IndexPath(row: 0, section: 1)
    }
    
    
    init(user: User) {
        self.user = user
        self.context = user.managedObjectContext!
        let request: NSFetchRequest<VocabularyCollection> = VocabularyCollection.fetchRequest()
        request.predicate = NSPredicate(value: true)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        try? fetchController.performFetch()
        super.init(style: .grouped)
        fetchController.delegate = self
        let recordName = UserDefaultsManager.selectedVocabularyCollectionRecordName
        selectedCollection = collections.first(where: { $0.recordMetadata.recordName == recordName })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        setupNavItems()
    }
    
    
    private func showDuplicateNameAlert(name: String) {
        let message = "\"\(name)\" is already in the collections"
        let alert = UIAlertController(title: "Found Duplicate", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func cellAddNewVocabularyCollection(_ cell: TextFieldCell, name: String) {
        let validator = StringValidator()
        let name = name.trimmingCharacters(in: .whitespaces)
        switch validator.validateNewName(name, existingNames: collections.map({ $0.name })) {
        case .empty:
            cell.setTextField(text: "")
        case .duplicate:
            cell.setTextField(text: "")
            showDuplicateNameAlert(name: name)
        case .unique:
            cell.setTextField(text: "")
            let collection = VocabularyCollection(user: user, name: name)
            if collections.isEmpty {
                selectedCollection = collection
                UserDefaultsManager.rememberSelectedVocabularyCollection(recordName: collection.recordMetadata.recordName)
            }
            context.quickSave()
        }
    }
    
    private func cellRenameVocabularyCollection(_ cell: TextFieldCell, collection: VocabularyCollection, newName: String) {
        let validator = StringValidator()
        let newName = newName.trimmingCharacters(in: .whitespaces)
        switch validator.validateNewName(newName, existingNames: collections.map({ $0.name })) {
        case .empty:
            cell.setTextField(text: collection.name)
        case .duplicate:
            cell.setTextField(text: collection.name)
            guard collection.name != newName else { return }
            showDuplicateNameAlert(name: newName)
        case .unique:
            collection.rename(newName)
            context.quickSave()
        }
    }
    
    private func cellDeleteVocabularyCollection(_ collection: VocabularyCollection) {
        if collection.vocabularies.isEmpty {
            deleteVocabluaryCollection(collection)
            return
        }
        let count = String(count: collection.vocabularies.count, single: "vocabulary", plural: "vocabularies")
        let message = "\(count) in the collection will be deleted."
        let confirmAlert = UIAlertController(title: "Delete Collection", message: message, preferredStyle: .alert)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] (action) in
            self?.deleteVocabluaryCollection(collection)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        confirmAlert.addAction(delete)
        confirmAlert.addAction(cancel)
        present(confirmAlert, animated: true, completion: nil)
    }
    
    private func deleteVocabluaryCollection(_ collection: VocabularyCollection) {
        let collectionRecordName = collection.recordMetadata.recordName
        self.context.delete(collection)
        self.context.quickSave()
        if collectionRecordName == UserDefaultsManager.selectedVocabularyCollectionRecordName {
            UserDefaultsManager.rememberSelectedVocabularyCollection(recordName: nil)
            self.selectedCollection = nil
        }
    }
}


extension UserProfileViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? collections.count : 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Vocabulary Collections" : nil
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? UITableView.automaticDimension : 0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueRegisteredCell(TextFieldCell.self, for: indexPath)
        cell.delegate = self
        if addNewCollectionIndexPath == indexPath {
            cell.setTextField(text: "")
            cell.setTextField(placeholder: "Add New Collection")
            cell.allowsEditing = true
            cell.accessoryType = .none
            cell.selectionStyle = .none
        } else {
            cell.setTextField(text: "\(collections[indexPath.row].name)")
            cell.setTextField(placeholder: "")
            cell.allowsEditing = false
            cell.accessoryType = selectedCollection === collections[indexPath.row] ? .checkmark : .none
            cell.selectionStyle = .default
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard indexPath != addNewCollectionIndexPath else { return [] }
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
            guard let self = self else { return }
            let collection = self.fetchController.object(at: indexPath)
            self.cellDeleteVocabularyCollection(collection)
        }
        let rename = UITableViewRowAction(style: .normal, title: "Rename") { (action, indexPath) in
            let cell = tableView.cellForRow(at: indexPath) as! TextFieldCell
            cell.allowsEditing = true
            cell.beginEditing()
        }
        rename.backgroundColor = UISegmentedControl().tintColor
        return [delete, rename]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if addNewCollectionIndexPath == indexPath {
            let cell = tableView.cellForRow(at: indexPath) as! TextFieldCell
            cell.beginEditing()
        } else {
            selectedCollection = collections[indexPath.row]
            UserDefaultsManager.rememberSelectedVocabularyCollection(recordName: selectedCollection!.recordMetadata.recordName)
            let visibleIndexPaths = tableView.indexPathsForVisibleRows ?? []
            tableView.reloadRows(at: visibleIndexPaths, with: .none)
            view.endEditing(true)
        }
    }
}


extension UserProfileViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert: tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .update: tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .delete: tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move: tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default: ()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}


extension UserProfileViewController: TextFieldCellDelegate {
    
    func textFieldCellDidEndEditing(_ cell: TextFieldCell, text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        if addNewCollectionIndexPath == indexPath {
            cellAddNewVocabularyCollection(cell, name: text)
        } else {
            let collection = collections[indexPath.row]
            cellRenameVocabularyCollection(cell, collection: collection, newName: text)
            cell.allowsEditing = false
        }
    }
}


extension UserProfileViewController {
    
    private func setupController() {
        navigationItem.title = "Profile"
        tableView.backgroundColor = .offWhiteBackground
        tableView.registerCell(TextFieldCell.self)
        tableView.tableHeaderView = UserProfileHeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: 150))
    }
    
    private func setupNavItems() {
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = done
    }
    
    @objc private func doneButtonTapped() {
        doneTappedHandler?()
    }
}
