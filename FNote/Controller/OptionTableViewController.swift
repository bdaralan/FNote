//
//  OptionTableViewController.swift
//  FNote
//
//  Created by Dara Beng on 1/19/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


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


class OptionTableViewController: UITableViewController {
    
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
    var allowAddNewOption: Bool = false
    
    /// The max number of characters a new option can have.
    var newOptionMaxCharacterCount: Int = 40
    
    /// Placeholder text for the new option text field.
    var newOptionPlaceholder: String = "Add New"
    
    /// A completion block that get called when a new option is added.
    /// The block passing in the new option `String` and its index.
    /// - note: Return `true` to tell the controller to add the option.
    var addNewOptionCompletion: ((_ newTag: String, _ index: Int) -> Void)?
    
    /// A completion block tag get called when an option is deleted.
    /// The block passing in the deleted option `String` and its index.
    var deleteOptionCompletion: ((Option) -> Void)?
    
    var doneCompletion: (() -> Void)?
    var cancelCompletion: (() -> Void)?
    
    lazy var navCancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSelecting))
    lazy var navDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneSelecting))
    
    private var addNewOptionIndexPath: IndexPath {
        return .init(row: 0, section: 1)
    }
    
    private let optionSection = 0
    
    
    init(selectMode: SelectMode, options: [Option], title: String?) {
        self.selectMode = selectMode
        self.options = options
        super.init(style: .grouped)
        navigationItem.title = title
        setupNavItems(showCancel: true, showDone: true, animated: false)
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
}


extension OptionTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return allowAddNewOption ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? options.count : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath == addNewOptionIndexPath {
            let cell = tableView.dequeueRegisteredCell(UserProfileTextFieldCell.self, for: indexPath)
            cell.delegate = self
            cell.allowsEditing = true
            cell.setTextField(placeholder: newOptionPlaceholder)
            cell.maxCharacterCount = newOptionMaxCharacterCount
            return cell
        } else {
            let cell = tableView.dequeueRegisteredCell(UITableViewCell.self, for: indexPath)
            let option = options[indexPath.row]
            cell.textLabel?.text = option.name
            cell.accessoryType = option.isSelected ? .checkmark : .none
            return cell
        }
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
        guard indexPath != addNewOptionIndexPath else { return [] }
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
        return [delete]
    }
}


extension OptionTableViewController: UserProfileTextFieldCellDelegate {
    
    func textFieldCellDidEndEditing(_ cell: UserProfileTextFieldCell, text: String) {
        cell.setTextField(text: "")
        let validator = StringValidator()
        let newTag = text.trimmingCharacters(in: .whitespaces)
        let existingTags = options.map({ $0.name })
        switch validator.validateNewName(newTag, existingNames: existingTags) {
        case .unique:
            let newOption = Option(name: newTag, isSelected: true)
            options.append(newOption)
            sortOptions(reloaded: false)
            let newIndex = options.firstIndex(of: newOption)! // unwrapped because just appended
            let newIndexPath = IndexPath(row: newIndex, section: optionSection)
            tableView.performBatchUpdates({
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }) { [weak self] (finished) in
                self?.tableView.selectRow(at: newIndexPath, animated: true, scrollPosition: .middle)
            }
            addNewOptionCompletion?(newTag, newIndex)
        case .duplicate:
            let alert = UIAlertController(title: "Duplicate", message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "Dismiss", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        case .empty: ()
        }
    }
    
    func textFieldCell(_ cell: UserProfileTextFieldCell, replacementTextFor overMaxCharacterCountText: String) -> String {
        return "\(overMaxCharacterCountText.prefix(newOptionMaxCharacterCount))"
    }
}


extension OptionTableViewController {

    private func setupController() {
        tableView.backgroundColor = .offWhiteBackground
        tableView.registerCell(UITableViewCell.self)
        tableView.registerCell(UserProfileTextFieldCell.self)
        tableView.rowHeight = 44
    }
    
    func setupNavItems(showCancel: Bool, showDone: Bool, animated: Bool) {
        let leftItem = showCancel ? navCancelItem : nil
        let rightItem = showDone ? navDoneItem : nil
        navigationItem.setLeftBarButton(leftItem, animated: animated)
        navigationItem.setRightBarButton(rightItem, animated: animated)
    }
    
    @objc private func doneSelecting() {
        doneCompletion?()
    }
    
    @objc private func cancelSelecting() {
        cancelCompletion?()
    }
}
