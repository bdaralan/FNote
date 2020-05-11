//
//  SettingViewController.swift
//  FNote
//
//  Created by Dara Beng on 3/25/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import Combine


class SettingViewController: UITableViewController {
    
    let preference: UserPreference
        
    let sections: [Section] = [
        .init(header: "APPEARANCE", footer: nil, rows: [.appearanceDark, .appearanceLight, .appearanceSystem]),
        .init(header: "CARD", footer: "If soft break is off, to create a new line, two return keys are required. Otherwise, the sentences continue", rows: [.generalKeyboardUsage, .markdownNoteToggle, .markdownSoftBreakToggle]),
        .init(header: "ABOUT", footer: nil, rows: [.version, .welcome])
    ]
    
    var onRowSelected: ((Row) -> Void)?
    
    private var cancellables: [AnyCancellable] = []
    
    private lazy var selectionHaptic = UISelectionFeedbackGenerator()
    
    
    // MARK: Static Cell
    
    let appearanceDarkCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .default)
        cell.textLabel?.text = "Dark"
        cell.tintColor = .label
        cell.onLayoutSubviews = cell.applyInsetSelectionRowStyle
        return cell
    }()
    
    let appearanceLightCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .default)
        cell.textLabel?.text = "Light"
        cell.tintColor = .label
        cell.onLayoutSubviews = cell.applyInsetSelectionRowStyle
        return cell
    }()
    
    let appearanceSystemCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .default)
        cell.textLabel?.text = "System"
        cell.accessoryType = .checkmark
        cell.tintColor = .label
        cell.onLayoutSubviews = cell.applyInsetSelectionRowStyle
        return cell
    }()
    
    let markdownNoteToggleCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .default)
        cell.textLabel?.text = "Use Markdown in Note"
        cell.useToggle(true)
        cell.onLayoutSubviews = cell.applyRowStyle
        cell.selectionStyle = .none
        return cell
    }()
    
    let markdownSoftBreakToggleCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .default)
        cell.textLabel?.text = "Use Soft Break"
        cell.useToggle(true)
        cell.onLayoutSubviews = cell.applyRowStyle
        cell.selectionStyle = .none
        return cell
    }()
    
    let versionCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1)
        cell.textLabel?.text = "Version"
        cell.detailTextLabel?.text = Bundle.main.appVersion
        cell.onLayoutSubviews = cell.applyRowStyle
        cell.selectionStyle = .none
        return cell
    }()
    
    let welcomeCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1)
        cell.textLabel?.text = "See Welcome Pages"
        cell.onLayoutSubviews = cell.applyInsetSelectionRowStyle
        return cell
    }()
    
    let generalKeyboardToggleCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .default)
        cell.textLabel?.text = "Show General Keyboard Usage"
        cell.useToggle(true)
        cell.onLayoutSubviews = cell.applyRowStyle
        cell.selectionStyle = .none
        return cell
    }()
    
    
    // MARK: Constructor
    
    init(preference: UserPreference) {
        self.preference = preference
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .zero
        tableView.separatorColor = UIColor.label.withAlphaComponent(0.04)
        setupObjectWillChange()
    }
}


extension SettingViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].header
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].footer
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        switch row {
        case .appearanceDark: return appearanceDarkCell
        case .appearanceLight: return appearanceLightCell
        case .appearanceSystem: return appearanceSystemCell
        case .generalKeyboardUsage: return generalKeyboardToggleCell
        case .markdownNoteToggle: return markdownNoteToggleCell
        case .markdownSoftBreakToggle: return markdownSoftBreakToggleCell
        case .version: return versionCell
        case .welcome: return welcomeCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = sections[indexPath.section].rows[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch row {
        
        case .appearanceDark:
            preference.colorScheme = .dark
            preference.applyColorScheme()
            preference.objectWillChange.send()
            selectionHaptic.selectionChanged()
            selectionHaptic.prepare()
        
        case .appearanceLight:
            preference.colorScheme = .light
            preference.applyColorScheme()
            preference.objectWillChange.send()
            selectionHaptic.selectionChanged()
            selectionHaptic.prepare()
        
        case .appearanceSystem:
            preference.colorScheme = .system
            preference.applyColorScheme()
            preference.objectWillChange.send()
            selectionHaptic.selectionChanged()
            selectionHaptic.prepare()
        
        case .welcome:
            selectionHaptic.selectionChanged()
            
        case .generalKeyboardUsage, .markdownNoteToggle, .markdownSoftBreakToggle, .version: break
        }
        
        onRowSelected?(row)
    }
}


// MARk: - User Preference Object Will Change

extension SettingViewController {
    
    private func setupObjectWillChange() {
        let handleToggle = #selector(handleToggleChanged)
        generalKeyboardToggleCell.toggle!.addTarget(self, action: handleToggle, for: .valueChanged)
        markdownNoteToggleCell.toggle!.addTarget(self, action: handleToggle, for: .valueChanged)
        markdownSoftBreakToggleCell.toggle!.addTarget(self, action: handleToggle, for: .valueChanged)
        
        let objectWillChange = preference
            .objectWillChange
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                self?.handleObjectWillChange()
            })
        cancellables.append(objectWillChange)
        preference.objectWillChange.send()
    }
    
    @objc private func handleToggleChanged(_ sender: UISwitch) {
        preference.objectWillChange.send()
        
        switch sender {
        
        case generalKeyboardToggleCell.toggle:
            preference.showGeneralKeyboardUsage = sender.isOn
        
        case markdownNoteToggleCell.toggle:
            preference.useMarkdown = sender.isOn
        
        case markdownSoftBreakToggleCell.toggle:
            preference.useMarkdownSoftBreak = sender.isOn
        
        default: fatalError("🧨 attempted to handle unknown toggle: \(sender) 🧨")
        }
    }
    
    private func handleObjectWillChange() {
        let colorScheme = preference.colorScheme
        appearanceDarkCell.accessoryType = colorScheme == .dark ? .checkmark : .none
        appearanceLightCell.accessoryType = colorScheme == .light ? .checkmark : .none
        appearanceSystemCell.accessoryType = colorScheme == .system ? .checkmark : .none
        
        generalKeyboardToggleCell.toggle!.setOn(preference.showGeneralKeyboardUsage, animated: true)
        
        markdownNoteToggleCell.toggle!.setOn(preference.useMarkdown, animated: true)
        markdownSoftBreakToggleCell.toggle!.setOn(preference.useMarkdownSoftBreak, animated: true)
        markdownSoftBreakToggleCell.toggle!.isEnabled = preference.useMarkdown
        markdownSoftBreakToggleCell.textLabel?.textColor = preference.useMarkdown ? .label : .tertiaryLabel
        
        tableView.reloadData()
    }
}


extension SettingViewController {
    
    struct Section {
        
        let header: String?
        
        let footer: String?
        
        let rows: [Row]
    }
    
    enum Row {
        case appearanceDark
        case appearanceLight
        case appearanceSystem
        
        case markdownNoteToggle
        case markdownSoftBreakToggle
        
        case generalKeyboardUsage
        
        case version
        case welcome
    }
}


// MARK: - Wrapper

struct SettingViewControllerWrapper: UIViewControllerRepresentable {
    
    var preference: UserPreference
    
    var onRowSelected: ((SettingViewController.Row) -> Void)?
    
    func makeUIViewController(context: Context) -> SettingViewController {
        let controller = SettingViewController(preference: preference)
        controller.tableView.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SettingViewController, context: Context) {
        uiViewController.onRowSelected = onRowSelected
    }
}


struct SettingViewController_Previews: PreviewProvider {
    static let preference = UserPreference.shared
    static var previews: some View {
        SettingViewControllerWrapper(preference: preference)
    }
}
