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
}


class OptionTableViewController: UITableViewController {
    
    private var options: [Option]
    
    var allowsMultipleSelection: Bool = false
    var selectCompletion: ((_ index: Int) -> Void)?
    var deselectCompletion: ((_ index: Int) -> Void)?
    
    
    init(options: [Option]) {
        self.options = options
        super.init(style: .grouped)
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueRegisteredCell(UITableViewCell.self, for: indexPath)
        let option = options[indexPath.row]
        cell.textLabel?.text = option.name
        cell.accessoryType = option.isSelected ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if allowsMultipleSelection {
            options[indexPath.row].isSelected.toggle()
        } else {
            options[indexPath.row].isSelected = true
            for (index, _) in options.enumerated() where index != indexPath.row {
                options[index].isSelected = false
            }
        }
        
        if options[indexPath.row].isSelected {
            selectCompletion?(indexPath.row)
        } else {
            deselectCompletion?(indexPath.row)
        }
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows ?? [indexPath], with: .none)
    }
}


extension OptionTableViewController {

    private func setupController() {
        tableView.backgroundColor = .offWhiteBackground
        tableView.registerCell(UITableViewCell.self)
        tableView.rowHeight = 44
    }
}
