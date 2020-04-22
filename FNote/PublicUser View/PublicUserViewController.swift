//
//  PublicUserViewController.swift
//  FNote
//
//  Created by Dara Beng on 4/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import Combine
import Down


class PublicUserViewController: UITableViewController {
    
    let viewModel: PublicUserViewModel
    
    private var sections: [Section] = [
        .init(header: "USERNAME", footer: nil, rows: [.username]),
        .init(header: "ABOUT", footer: nil, rows: [.userBio])
    ]
    
    var onRowSelected: ((Row) -> Void)?
    
    private var cancellables = [AnyCancellable]()
    
    let usernameCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1)
        cell.onLayoutSubviews = cell.applyInsetSelectionRowStyle
        return cell
    }()
    
    let userBioCell: TableViewCell<UITextView> = {
        let cell = TableViewCell<UITextView>(style: .default, reuseIdentifier: nil)
        cell.onLayoutSubviews = cell.applyInsetSelectionRowStyle
        cell.uiView.backgroundColor = .clear
        cell.uiView.isEditable = false
        cell.uiView.isUserInteractionEnabled = false
        cell.uiView.font = .preferredFont(forTextStyle: .body)
        cell.uiView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        return cell
    }()
    
    let saveChangesCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .default)
        cell.textLabel?.text = "Save Changes"
        cell.textLabel?.textColor = .appAccent
        cell.textLabel?.textAlignment = .center
        cell.onLayoutSubviews = cell.applyInsetSelectionRowStyle
        return cell
    }()
    
    private var userBioCellHeight: CGFloat = 200
    
    
    // MARK: Constructor
    
    init(viewModel: PublicUserViewModel) {
        self.viewModel = viewModel
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCellWithViewModel()
        setupViewModelObjectWillChange()
    }
    
    
    // MARK: Data Source & Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = sections[indexPath.section].rows[indexPath.row]
        switch row {
        case .username: return 60
        case .userBio: return max(120, userBioCellHeight)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].header
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        switch row {
        case .username: return usernameCell
        case .userBio: return userBioCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = sections[indexPath.section].rows[indexPath.row]
        onRowSelected?(row)
    }
        
    
    // MARK: Setup
    
    private func setupViewModelObjectWillChange() {
        viewModel.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.updateCellWithViewModel()
            })
            .store(in: &cancellables)
    }
    
    private func updateCellWithViewModel() {
        usernameCell.textLabel?.text = viewModel.username.isEmpty ? "required" : viewModel.username
        usernameCell.textLabel?.textColor = viewModel.username.isEmpty ? .red : .label
        
        if userBioCell.uiView.text != viewModel.userBio {
            let down = Down(markdownString: viewModel.userBio)
            let downColors: ColorCollection
            
            if traitCollection.userInterfaceStyle == .dark {
                downColors = DarkSchemeColorCollection()
            } else {
                downColors = LightSchemeColorCollection()
            }
            
            userBioCell.uiView.attributedText = down.markdown(options: .hardBreaks, colors: downColors)
            updateUserBioCellHeight()
        }
    }
    
    /// Compute a new height for bio cell based on its text view height and inset.
    private func updateUserBioCellHeight() {
        let textView = userBioCell.uiView
        textView.sizeToFit()
        
        let inset = textView.contentInset
        let height = textView.contentSize.height
        userBioCellHeight = height + inset.top + inset.bottom
        
        let cellIndex = IndexPath(row: 0, section: 1)
        tableView.reloadRows(at: [cellIndex], with: .none)
    }
}


extension PublicUserViewController {
    
    struct Section {
        
        let header: String?
        
        let footer: String?
        
        let rows: [Row]
    }
    
    enum Row {
        case username
        case userBio
    }
}



// MARK: - Wrapper

struct PublicUserViewControllerWrapper: UIViewControllerRepresentable {
    
    @ObservedObject var viewModel: PublicUserViewModel
    
    var onRowSelected: ((PublicUserViewController.Row) -> Void)?
    
    func makeUIViewController(context: Context) -> PublicUserViewController {
        let controller = PublicUserViewController(viewModel: viewModel)
        controller.tableView.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PublicUserViewController, context: Context) {
        uiViewController.onRowSelected = onRowSelected
    }
}

