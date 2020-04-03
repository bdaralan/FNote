//
//  PublishCollectionViewController.swift
//  FNote
//
//  Created by Dara Beng on 3/21/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import Combine


class PublishCollectionViewController: UITableViewController {
        
    // MARK: Property
    
    let viewModel: PublishCollectionFormModel
    
    var onRowSelected: ((PublishFormSection.Row) -> Void)?
    
    let sections: [PublishFormSection] = [
        .init(header: "AUTHOR", footer: nil, rows: [.authorName]),
        .init(header: "COLLECTION TO PUBLISH", footer: nil, rows: [.collection]),
        .init(header: "PUBLISH DETAILS", footer: nil, rows: [.collectionName, .collectionDescription, .collectionTag, .collectionPrimaryLanguage, .collectionSecondaryLanguage]),
        .init(header: "PUBLISH OPTIONS", footer: nil, rows: [.includeNote]),
        .init(header: nil, footer: nil, rows: [.publishAction])
    ]
    
    private var viewModelSubscribers = [AnyCancellable]()
    
    // MARK: Cell
    
    let authorNameCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.onLayoutSubviews = cell.applyRowStyle
        return cell
    }()
    
    let collectionNameCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.onLayoutSubviews = cell.applyRowStyle
        return cell
    }()
    
    let collectionCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.onLayoutSubviews = cell.applyRowStyle
        return cell
    }()
    
    let collectionDescriptionCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.onLayoutSubviews = cell.applyRowStyle
        return cell
    }()
    
    let tagCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.onLayoutSubviews = cell.applyRowStyle
        return cell
    }()
    
    let primaryLanguageCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.onLayoutSubviews = cell.applyRowStyle
        return cell
    }()
    
    let secondaryLanguageCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.onLayoutSubviews = cell.applyRowStyle
        return cell
    }()
    
    let includeNoteCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .default, reuseIdentifier: nil)
        cell.useToggle(true)
        cell.selectionStyle = .none
        cell.onLayoutSubviews = cell.applyRowStyle
        return cell
    }()
    
    let publishActionCell: TableViewCell<UILabel> = {
        let cell = TableViewCell<UILabel>(style: .default, reuseIdentifier: nil)
        cell.uiView.textAlignment = .center
        cell.uiView.textColor = .label
        cell.uiView.font = .systemFont(ofSize: UIFont.labelFontSize, weight: .black)
        cell.backgroundColor = .noteCardBackground
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.label.cgColor
        return cell
    }()
    
    
    // MARK: Constructor
    
    init(viewModel: PublishCollectionFormModel) {
        self.viewModel = viewModel
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupViewModelObjectWillChange()
    }
    
    private func setupViewModelObjectWillChange() {
        let objectWillChange = viewModel
            .objectWillChange
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.handleViewModelObjectWillChange()
            })
        
        viewModelSubscribers.append(objectWillChange)
        
        includeNoteCell.toggle!.addTarget(self, action: #selector(handleToggleChanged), for: .valueChanged)
        
        viewModel.objectWillChange.send()
    }
    
    private func handleViewModelObjectWillChange() {
        authorNameCell.detailTextLabel?.text = viewModel.uiAuthorName
        authorNameCell.detailTextLabel?.textColor = viewModel.authorName.trimmed().isEmpty ? .quaternaryLabel : .secondaryLabel
        
        collectionCell.detailTextLabel?.text = viewModel.uiCollectionName
        collectionCell.detailTextLabel?.textColor = viewModel.publishCollection == nil ? .quaternaryLabel : .secondaryLabel
        
        collectionNameCell.detailTextLabel?.text = viewModel.uiCollectionPublishName
        collectionNameCell.detailTextLabel?.textColor = viewModel.publishCollectionName.trimmed().isEmpty ? .quaternaryLabel : .secondaryLabel
        
        collectionDescriptionCell.detailTextLabel?.text = viewModel.uiCollectionDescription
        collectionDescriptionCell.detailTextLabel?.textColor = viewModel.publishDescription.trimmed().isEmpty ? .quaternaryLabel : .secondaryLabel
        
        tagCell.detailTextLabel?.text = viewModel.uiCollectionTags
        tagCell.detailTextLabel?.textColor = viewModel.publishTags.isEmpty ? .quaternaryLabel : .secondaryLabel
        
        primaryLanguageCell.detailTextLabel?.text = viewModel.uiCollectionPrimaryLanguage
        primaryLanguageCell.detailTextLabel?.textColor = viewModel.publishPrimaryLanguage == nil ? .quaternaryLabel : .secondaryLabel
        
        secondaryLanguageCell.detailTextLabel?.text = viewModel.uiCollectionSecondaryLanguage
        secondaryLanguageCell.detailTextLabel?.textColor = viewModel.publishSecondaryLanguage == nil ? .quaternaryLabel : .secondaryLabel
        
        includeNoteCell.toggle?.setOn(viewModel.includesNote, animated: true)
        
        let enablePublish = viewModel.hasValidInputs
        publishActionCell.uiView.text = viewModel.commitTitle
        publishActionCell.isUserInteractionEnabled = enablePublish
        publishActionCell.alpha = enablePublish ? 1 : 0.4
    }
    
    @objc private func handleToggleChanged(_ sender: UISwitch) {
        guard sender === includeNoteCell.toggle else { return }
        viewModel.includesNote = sender.isOn
    }
    
    
    // MARK: DataSource & Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].header
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowKind = sections[indexPath.section].rows[indexPath.row]
        
        switch rowKind {
            
        case .authorName:
            authorNameCell.textLabel?.text = "Name"
            return authorNameCell
            
        case .collectionName:
            collectionNameCell.textLabel?.text = "Collection Name"
            return collectionNameCell
            
        case .collection:
            collectionCell.textLabel?.text = "Collection"
            return collectionCell
            
        case .collectionDescription:
            collectionDescriptionCell.textLabel?.text = "Description"
            return collectionDescriptionCell
            
        case .collectionTag:
            tagCell.textLabel?.text = "Tags"
            return tagCell
            
        case .collectionPrimaryLanguage:
            primaryLanguageCell.textLabel?.text = "Primary Language"
            return primaryLanguageCell
            
        case .collectionSecondaryLanguage:
            secondaryLanguageCell.textLabel?.text = "Secondary Language"
            return secondaryLanguageCell
            
        case .includeNote:
            includeNoteCell.textLabel?.text = "Include Card's Note"
            publishActionCell.uiView.text = viewModel.commitTitle
            return includeNoteCell
            
        case .publishAction:
            return publishActionCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowKind = sections[indexPath.section].rows[indexPath.row]
        
        onRowSelected?(rowKind)
        
        if rowKind == .publishAction {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}


extension PublishCollectionViewController: UITextFieldDelegate {
    
    private func setupView() {
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
    }
}


 // MARK: - Wrapper

struct PublishCollectionViewControllerWrapper: UIViewControllerRepresentable {
    
    @ObservedObject var viewModel: PublishCollectionFormModel
    
    var onRowSelected: ((PublishFormSection.Row) -> Void)?
    
    func makeUIViewController(context: Context) -> PublishCollectionViewController {
        let controller = PublishCollectionViewController(viewModel: viewModel)
        controller.tableView.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PublishCollectionViewController, context: Context) {
        uiViewController.onRowSelected = onRowSelected
    }
}


struct Preview: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                PublishCollectionViewControllerWrapper(viewModel: .init())
                    .navigationBarTitle("Publish Collection", displayMode: .inline)
            }
            NavigationView {
                PublishCollectionViewControllerWrapper(viewModel: .init())
                    .navigationBarTitle("Publish Collection", displayMode: .inline)
            }
            .colorScheme(.dark)
        }
    }
}


// MARK: - Model & Enum

struct PublishFormSection {
    
    let header: String?
    
    let footer: String?
    
    let rows: [Row]
    
    enum Row {
        case authorName
        case collection
        case collectionName
        case collectionDescription
        case collectionTag
        case collectionPrimaryLanguage
        case collectionSecondaryLanguage
        case includeNote
        case publishAction
    }
}

enum PublishFormPublishState {
    case editing
    case submitting
    case published
    case rejected
}
