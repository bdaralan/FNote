//
//  OptionTableViewController.swift
//  FNote
//
//  Created by Dara Beng on 1/19/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


class OptionTableViewController: UITableViewController {
    
    var options: [String]
    var selectedOptions: [String]
    
    var selectOptionHandler: ((_ index: Int) -> Void)?
    var deselectOptionHandler: ((_ index: Int) -> Void)?
    
    
    init(options: [String], selectedOptions: [String]) {
        self.options = options
        self.selectedOptions = selectedOptions
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
        let isSelectedOption = selectedOptions.contains(options[indexPath.row])
        cell.textLabel?.text = options[indexPath.row]
        cell.accessoryType = isSelectedOption ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueRegisteredCell(UITableViewCell.self, for: indexPath)
        let willSelectOption = cell.accessoryType == .none
        if willSelectOption {
            cell.accessoryType = .checkmark
            selectOptionHandler?(indexPath.row)
        } else {
            cell.accessoryType = .none
            deselectOptionHandler?(indexPath.row)
        }
    }
}


extension OptionTableViewController {

    private func setupController() {
        tableView.backgroundColor = .offWhiteBackground
        tableView.registerCell(UITableViewCell.self)
    }
}
