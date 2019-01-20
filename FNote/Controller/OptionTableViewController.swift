//
//  OptionTableViewController.swift
//  FNote
//
//  Created by Dara Beng on 1/19/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


protocol OptionTableViewControllerDataSoureDelegate: class {
    
    func numberOfOptions(in controller: OptionTableViewController) -> Int
    
    func optionTableViewController(_ controller: OptionTableViewController, optionAtIndex index: Int) -> String
    
    func optionTableViewController(_ controller: OptionTableViewController, showsCheckmarkAt index: Int) -> Bool
    
    func optionTableViewController(_ controller: OptionTableViewController, didSelectOptionAtIndex index: Int)
}


class OptionTableViewController: UITableViewController {
    
    weak var dataSourceDelegate: OptionTableViewControllerDataSoureDelegate?
    
    init() {
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
        return dataSourceDelegate?.numberOfOptions(in: self) ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueRegisteredCell(UITableViewCell.self, for: indexPath)
        let optionIndex = indexPath.row
        cell.textLabel?.text = dataSourceDelegate?.optionTableViewController(self, optionAtIndex: optionIndex)
        
        let showsCheckmark = dataSourceDelegate?.optionTableViewController(self, showsCheckmarkAt: optionIndex) ?? false
        cell.accessoryType = showsCheckmark ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataSourceDelegate?.optionTableViewController(self, didSelectOptionAtIndex: indexPath.row)
    }
}


extension OptionTableViewController {

    private func setupController() {
        tableView.backgroundColor = .offWhiteBackground
        tableView.registerCell(UITableViewCell.self)
    }
}
