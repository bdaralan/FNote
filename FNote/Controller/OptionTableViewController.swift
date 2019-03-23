//
//  OptionTableViewController.swift
//  FNote
//
//  Created by Dara Beng on 1/19/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


extension OptionTableViewController {
    
    struct Option {
        let name: String
        var isSelected: Bool
    }
    
    enum Mode {
        /// Must select an option
        case singleSelection
        
        /// Select an option or none
        case singleSelectionOrNone
        
        /// Select many options or none
        case multipleSelection
    }
}


class OptionTableViewController: UITableViewController {
    
    /// The available selecting options
    private var options: [Option]
    
    /// Set to `true` to allow selecting multiple options.
    var allowsMultipleSelection: Bool = false {
        didSet { setupNavDoneItem(enabled: allowsMultipleSelection) }
    }
    
    /// A completion block that get called when an option is selected.
    var selectCompletion: ((_ index: Int) -> Void)?
    
    /// A completion block that get called when finishing selecting.
    var multipleSelectionCompletion: (([Int]) -> Void)?
    
    /// A completion block that get called when an option is deselected.
    /// - note: Only get called when using mode `multipleSelection` or `singleSelectionOrNone`.
    var deselectCompletion: ((_ index: Int) -> Void)?
    
    /// Set to `true` to allow adding new options.
    var allowAddNewOption: Bool = false
    
    /// A completion block that get called when a new option is added
    var addNewOptionCompletion: (() -> Void)?
    
    private var addNewOptionIndexPath: IndexPath {
        return .init(row: 0, section: 1)
    }
    
    
    init(options: [Option], title: String?) {
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
            cell.setTextField(placeholder: "Add New Tag")
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
        if allowsMultipleSelection {
            let index = indexPath.row
            options[index].isSelected.toggle()
            tableView.reloadRows(at: [indexPath], with: .none)
            if options[index].isSelected {
                selectCompletion?(index)
            } else {
                deselectCompletion?(index)
            }
        } else {
            let selectedIndex = indexPath.row
            options.enumerated().forEach { (index, _) in
                options[index].isSelected = index == selectedIndex
            }
            if let indexPaths = tableView.indexPathsForVisibleRows {
                tableView.reloadRows(at: indexPaths, with: .none)
            }
            selectCompletion?(selectedIndex)
        }
    }
}


extension OptionTableViewController: UserProfileTextFieldCellDelegate {
    
    func textFieldCellDidEndEditing(_ cell: UserProfileTextFieldCell, text: String) {
        cell.setTextField(text: "")
        print(text)
        #warning("TODO: create new tag if not duplicate")
    }
}


extension OptionTableViewController {

    private func setupController() {
        tableView.backgroundColor = .offWhiteBackground
        tableView.registerCell(UITableViewCell.self)
        tableView.registerCell(UserProfileTextFieldCell.self)
        tableView.rowHeight = 44
    }
    
    private func setupNavDoneItem(enabled: Bool) {
        if enabled {
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneSelectingOptions))
            navigationItem.rightBarButtonItem = done
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc private func doneSelectingOptions() {
        let selectedIndexs = options.enumerated().compactMap({ return $1.isSelected ? $0 : nil })
        multipleSelectionCompletion?(selectedIndexs)
    }
}
