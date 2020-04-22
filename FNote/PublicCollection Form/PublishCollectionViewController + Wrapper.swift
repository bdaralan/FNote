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
        .init(header: nil, footer: nil, rows: [.authorName]),
        .init(header: "COLLECTION TO PUBLISH", footer: nil, rows: [.collection]),
        .init(header: "PUBLISH DETAILS", footer: nil, rows: [.collectionName, .collectionDescription, .collectionTag, .collectionPrimaryLanguage, .collectionSecondaryLanguage]),
        .init(header: "PUBLISH OPTIONS", footer: nil, rows: [.includeNote]),
        .init(header: nil, footer: nil, rows: [.publishAction])
    ]
    
    private var cancellables = [AnyCancellable]()
    
    // MARK: Cell
    
    let authorNameCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1)
        cell.textLabel?.text = "Author"
        cell.isUserInteractionEnabled = false
        cell.onLayoutSubviews = cell.applyInsetSelectionRowStyle
        return cell
    }()
    
    let collectionNameCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1)
        cell.textLabel?.text = "Collection Name"
        cell.accessoryType = .disclosureIndicator
        cell.onLayoutSubviews = cell.applyInsetSelectionRowStyle
        return cell
    }()
    
    let collectionCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1)
        cell.textLabel?.text = "Collection"
        cell.accessoryType = .disclosureIndicator
        cell.onLayoutSubviews = cell.applyInsetSelectionRowStyle
        return cell
    }()
    
    let collectionDescriptionCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1)
        cell.textLabel?.text = "Description"
        cell.accessoryType = .disclosureIndicator
        cell.onLayoutSubviews = cell.applyInsetSelectionRowStyle
        return cell
    }()
    
    let tagCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1)
        cell.textLabel?.text = "Tags"
        cell.accessoryType = .disclosureIndicator
        cell.onLayoutSubviews = cell.applyInsetSelectionRowStyle
        return cell
    }()
    
    let primaryLanguageCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1)
        cell.textLabel?.text = "Primary Language"
        cell.accessoryType = .disclosureIndicator
        cell.onLayoutSubviews = cell.applyInsetSelectionRowStyle
        return cell
    }()
    
    let secondaryLanguageCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1)
        cell.textLabel?.text = "Secondary Language"
        cell.accessoryType = .disclosureIndicator
        cell.onLayoutSubviews = cell.applyInsetSelectionRowStyle
        return cell
    }()
    
    let includeNoteCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .default)
        cell.textLabel?.text = "Include Card's Note"
        cell.useToggle(true)
        cell.onLayoutSubviews = cell.applyInsetSelectionRowStyle
        return cell
    }()
    
    let publishActionCell: TableViewCell<UILabel> = {
        let cell = TableViewCell<UILabel>(style: .default, reuseIdentifier: nil)
        cell.uiView.textAlignment = .center
        cell.uiView.textColor = .appAccent
        cell.uiView.font = .systemFont(ofSize: UIFont.labelFontSize, weight: .black)
        cell.backgroundColor = .noteCardBackground
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.appAccent.cgColor
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
        case .authorName: return authorNameCell
        case .collectionName: return collectionNameCell
        case .collection: return collectionCell
        case .collectionDescription: return collectionDescriptionCell
        case .collectionTag: return tagCell
        case .collectionPrimaryLanguage: return primaryLanguageCell
        case .collectionSecondaryLanguage: return secondaryLanguageCell
        case .includeNote: return includeNoteCell
        case .publishAction: return publishActionCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowKind = sections[indexPath.section].rows[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        onRowSelected?(rowKind)
        
        if rowKind == .publishAction {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}


// MARK: - Setup

extension PublishCollectionViewController {
    
    private func setupView() {
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
    }
    
    private func setupViewModelObjectWillChange() {
        viewModel.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.handleViewModelObjectWillChange()
            })
            .store(in: &cancellables)
        
        includeNoteCell.toggle!.addTarget(self, action: #selector(handleToggleChanged), for: .valueChanged)
        
        viewModel.objectWillChange.send()
    }
    
    private func handleViewModelObjectWillChange() {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: viewModel.author.isValid ? UIColor.secondaryLabel : .red
        ]
        let attributeString = NSAttributedString(string: viewModel.uiAuthorName, attributes: attributes)
        authorNameCell.detailTextLabel?.attributedText = attributeString
        
        collectionCell.detailTextLabel?.text = viewModel.uiCollectionName
        collectionCell.detailTextLabel?.textColor = viewModel.publishCollection == nil ? .quaternaryLabel : .secondaryLabel
        
        collectionNameCell.detailTextLabel?.text = viewModel.uiCollectionPublishName
        collectionNameCell.detailTextLabel?.textColor = viewModel.publishCollectionName.trimmed().isEmpty ? .quaternaryLabel : .secondaryLabel
        
        let descriptionColor: UIColor
        if viewModel.publishDescription.count > viewModel.publishDescriptionLimit {
            descriptionColor = .red
        } else {
            descriptionColor = viewModel.publishDescription.isEmpty ? .quaternaryLabel : .secondaryLabel
        }
        collectionDescriptionCell.detailTextLabel?.text = viewModel.uiCollectionDescription
        collectionDescriptionCell.detailTextLabel?.textColor = descriptionColor
        
        tagCell.detailTextLabel?.text = viewModel.uiCollectionTags
        tagCell.detailTextLabel?.textColor = viewModel.publishTags.isEmpty ? .quaternaryLabel : .secondaryLabel
        
        primaryLanguageCell.detailTextLabel?.text = viewModel.uiCollectionPrimaryLanguage
        primaryLanguageCell.detailTextLabel?.textColor = viewModel.publishPrimaryLanguage == nil ? .quaternaryLabel : .secondaryLabel
        
        secondaryLanguageCell.detailTextLabel?.text = viewModel.uiCollectionSecondaryLanguage
        secondaryLanguageCell.detailTextLabel?.textColor = viewModel.publishSecondaryLanguage == nil ? .quaternaryLabel : .secondaryLabel
        
        includeNoteCell.toggle?.setOn(viewModel.includesNote, animated: true)
        
        let enablePublish = viewModel.hasValidInputs
        let textColor = publishActionCell.uiView.textColor
        publishActionCell.uiView.text = viewModel.commitTitle
        publishActionCell.isUserInteractionEnabled = enablePublish
        publishActionCell.uiView.textColor = textColor?.withAlphaComponent(enablePublish ? 1 : 0.4)
        publishActionCell.layer.borderColor = textColor?.withAlphaComponent(enablePublish ? 1 : 0.4).cgColor
        
        tableView.reloadData()
    }
    
    @objc private func handleToggleChanged(_ sender: UISwitch) {
        guard sender === includeNoteCell.toggle else { return }
        viewModel.includesNote = sender.isOn
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
    static let viewModel: PublishCollectionFormModel = {
        let user = PublicUser(userID: "someID0409", username: "DLan", about: "This is a test user.")
        let model = PublishCollectionFormModel(user: user)
        return model
    }()
    static var previews: some View {
        Group {
            NavigationView {
                PublishCollectionViewControllerWrapper(viewModel: viewModel)
                    .navigationBarTitle("Publish Collection", displayMode: .inline)
            }
            NavigationView {
                PublishCollectionViewControllerWrapper(viewModel: viewModel)
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
