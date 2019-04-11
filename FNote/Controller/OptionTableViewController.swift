//
//  OptionTableViewController.swift
//  FNote
//
//  Created by Dara Beng on 1/19/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit



class OptionTableViewController: UITableViewController, NavigationItemTogglable {
    
    let selectMode: SelectMode
    
    /// The available selecting options
    private(set) var options: [Option]
    
    /// A completion block that get called when an option is selected.
    /// The block passing in the selected index.
    var selectCompletion: ((_ index: Int) -> Void)?
    
    /// A completion block that get called when an option is deselected.
    /// The block passing in the deselected index.
    /// - note: This block only get called if the select mode is `multiple` or `singleOrNone`.
    var deselectCompletion: ((_ index: Int) -> Void)?
    
    /// Set to `true` to allow adding new options which will display a text field.
    var allowAddNewOption = false
    
    /// The max number of characters a new option can have.
    var newOptionMaxCharacterCount = 40
    
    /// Placeholder text for the new option text field.
    var newOptionPlaceholder = "Add New"
    
    /// A completion block that get called when a new option is added.
    /// The block passing in the new option `String` and its index.
    /// - note: Return `true` to tell the controller to add the option.
    var addNewOptionCompletion: ((_ newTag: String, _ index: Int) -> Void)?
    
    /// Set to `true` to allow renaming options.
    var allowRenameOption = false
    
    /// A completion block get called when an option is renamed.
    /// The block passing in the old and the updated options.
    var renameOptionCompletion: ((Option, Option) -> Void)?
    
    /// Set to `true` to allow deleting options.
    var allowDeleteOption = false
    
    /// A completion block tag get called when an option is deleted.
    var deleteOptionCompletion: ((Option) -> Void)?
    
    var doneCompletion: (() -> Void)?
    var cancelCompletion: (() -> Void)?
    
    private var addNewOptionIndexPath: IndexPath {
        return .init(row: 0, section: 1)
    }
    
    private let optionSection = 0
    
    
    init(selectMode: SelectMode, options: [Option], title: String?) {
        self.selectMode = selectMode
        self.options = options
        super.init(style: .grouped)
        navigationItem.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }
    
    func sortOptions(reloaded: Bool) {
        options.sort(by: { $0.name < $1.name })
        guard reloaded else { return }
        tableView.reloadData()
    }
    
    private func addNewOption(name: String) {
        let newOption = Option(name: name, isSelected: true)
        options.append(newOption)
        sortOptions(reloaded: false)
        let newIndex = options.firstIndex(of: newOption)! // unwrapped because just appended
        let newIndexPath = IndexPath(row: newIndex, section: optionSection)
        tableView.performBatchUpdates({
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }) { [weak self] (finished) in
            self?.tableView.selectRow(at: newIndexPath, animated: true, scrollPosition: .middle)
        }
        addNewOptionCompletion?(name, newIndex)
    }
    
    private func renameOption(at index: Int, newName: String) {
        let currentOption = options[index]
        let updatedOption = Option(name: newName, isSelected: options[index].isSelected)
        options[index] = updatedOption
        renameOptionCompletion?(currentOption, updatedOption)
    }
    
    func doneBarItemTapped() {
        doneCompletion?()
    }
    
    func cancelBarItemTapped() {
        cancelCompletion?()
    }
}


extension OptionTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return allowAddNewOption ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? options.count : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueRegisteredCell(TextFieldCell.self, for: indexPath)
        cell.delegate = self
        if indexPath == addNewOptionIndexPath {
            cell.allowsEditing = true
            cell.setTextField(placeholder: newOptionPlaceholder)
            cell.accessoryType = .none
        } else {
            let option = options[indexPath.row]
            cell.allowsEditing = false
            cell.setTextField(text: option.name)
            cell.accessoryType = option.isSelected ? .checkmark : .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch selectMode {
        case .single:
            let selectedIndex = indexPath.row
            options.enumerated().forEach({ options[$0.offset].isSelected = $0.offset == selectedIndex })
            tableView.reloadVisibleRows(animation: .none)
            selectCompletion?(selectedIndex)
        
        case .singleOrNone:
            let selectedIndex = indexPath.row
            options[selectedIndex].isSelected.toggle()
            for (index, _) in options.enumerated() where index != selectedIndex {
                options[index].isSelected = false
            }
            tableView.reloadVisibleRows(animation: .none)
            if options[selectedIndex].isSelected {
                selectCompletion?(selectedIndex)
            } else {
                deselectCompletion?(selectedIndex)
            }
            
        case .multiple:
            let selectedIndex = indexPath.row
            options[selectedIndex].isSelected.toggle()
            tableView.reloadRows(at: [indexPath], with: .none)
            if options[selectedIndex].isSelected {
                selectCompletion?(selectedIndex)
            } else {
                deselectCompletion?(selectedIndex)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var editingActions = [UITableViewRowAction]()
        guard indexPath != addNewOptionIndexPath else { return editingActions }
        if allowDeleteOption {
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
                guard let self = self else { return }
                let index = indexPath.row
                if self.options[index].isSelected {
                    self.deselectCompletion?(index)
                }
                let option = self.options.remove(at: index)
                let indexPath = IndexPath(row: index, section: self.optionSection)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.deleteOptionCompletion?(option)
            }
            editingActions.append(delete)
        }
        
        if allowRenameOption {
            let rename = UITableViewRowAction(style: .default, title: "Rename") { (action, indexPath) in
                let cell = tableView.cellForRow(at: indexPath) as! TextFieldCell
                cell.allowsEditing = true
                cell.beginEditing()
            }
            rename.backgroundColor = .uiControlTint
            editingActions.append(rename)
        }
        
        return editingActions
    }
}


extension OptionTableViewController: TextFieldCellDelegate {
    
    func textFieldCellDidEndEditing(_ cell: TextFieldCell, text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        cell.allowsEditing = indexPath == addNewOptionIndexPath
        
        let validator = StringValidator()
        let optionName = text.trimmingCharacters(in: .whitespaces)
        
        switch validator.validateNewName(optionName, existingNames: options.map({ $0.name })) {
        case .unique:
            if addNewOptionIndexPath == indexPath {
                cell.setTextField(text: "")
                addNewOption(name: optionName)
            } else {
                cell.setTextField(text: optionName)
                renameOption(at: indexPath.row, newName: optionName)
            }
        case .duplicate:
            let isAddNewOption = addNewOptionIndexPath == indexPath
            let isOptionRenamed = options[indexPath.row].name != optionName
            if isAddNewOption || isOptionRenamed {
                let alert = UIAlertController(title: "Duplicate", message: nil, preferredStyle: .alert)
                let dismiss = UIAlertAction(title: "Dismiss", style: .default) { [weak self] (action) in
                    guard let self = self, isAddNewOption == false else { return }
                    cell.setTextField(text: self.options[indexPath.row].name)
                }
                alert.addAction(dismiss)
                present(alert, animated: true, completion: nil)
            }
        case .empty: ()
        }
    }
    
    func textFieldCell(_ cell: TextFieldCell, didChangeText text: String) {
        guard text.count > newOptionMaxCharacterCount else { return }
        cell.setTextField(text: "\(text.prefix(newOptionMaxCharacterCount))")
    }
}


extension OptionTableViewController {

    private func setupController() {
        tableView.backgroundColor = .offWhiteBackground
        tableView.registerCell(TextFieldCell.self)
        tableView.rowHeight = 44
    }
}


extension OptionTableViewController {
    
    struct Option: Equatable {
        let name: String
        var isSelected: Bool
        
        static func == (lhs: Option, rhs: Option) -> Bool {
            return lhs.name == rhs.name
        }
    }
    
    enum SelectMode {
        /// Must select an option
        case single
        
        /// Select an option or none
        case singleOrNone
        
        /// Select many options or none
        case multiple
    }
}
