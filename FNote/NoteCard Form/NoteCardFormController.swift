//
//  NoteCardViewController.swift
//  FNote
//
//  Created by Dara Beng on 3/22/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import Combine


class NoteCardFormController: UITableViewController {
    
    // MARK: Property
    
    let viewModel: NoteCardFormModel
    
    var onRowSelected: ((NoteCardFormRowKind) -> Void)?
    
    let sections: [[NoteCardFormRowKind]] = [
        [.native, .translation],
        [.collection],
        [.formality],
        [.favorite, .relationship, .tag, .note]
    ]
    
    private var viewModelSubscribers: [AnyCancellable] = []
    
    private lazy var selectionHaptic = UISelectionFeedbackGenerator()
    
    
    // MARK: Static Cell
    
    let nativeCell: TableViewCell<TextFieldInputView> = {
        let cell = TableViewCell<TextFieldInputView>(style: .default, reuseIdentifier: nil)
        cell.uiView.label.text = "native"
        cell.uiView.textField.clearButtonMode = .whileEditing
        cell.uiView.textField.font = .preferredFont(forTextStyle: .headline)
        cell.setStackViewInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
        cell.stackView.spacing = 4
        cell.onLayoutSubviews = cell.applyRowStyle
        cell.selectionStyle = .none
        return cell
    }()
    
    let translationCell: TableViewCell<TextFieldInputView> = {
        let cell = TableViewCell<TextFieldInputView>(style: .default, reuseIdentifier: nil)
        cell.uiView.label.text = "translation"
        cell.uiView.textField.clearButtonMode = .whileEditing
        cell.uiView.textField.font = .preferredFont(forTextStyle: .body)
        cell.setStackViewInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
        cell.onLayoutSubviews = cell.applyRowStyle
        cell.selectionStyle = .none
        return cell
    }()
    
    let collectionCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1, reuseIdentifier: nil)
        cell.accessoryType = .disclosureIndicator
        cell.onLayoutSubviews = cell.applyRowStyle
        cell.selectionStyle = .none
        return cell
    }()
    
    let formalityCell: TableViewCell<UISegmentedControl> = {
        let cell = TableViewCell<UISegmentedControl>(style: .default, reuseIdentifier: nil)
        cell.onLayoutSubviews = cell.applyRowStyle
        cell.selectionStyle = .none
        return cell
    }()
    
    let favoriteCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1, reuseIdentifier: nil)
        cell.imageView?.image = createRowIcon(imageName: "star")
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.tintColor = .label
        cell.textLabel?.text = "Favorite"
        cell.useToggle(true)
        cell.onLayoutSubviews = cell.applyRowStyle
        cell.selectionStyle = .none
        return cell
    }()
    
    let relationshipCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1, reuseIdentifier: nil)
        cell.imageView?.image = createRowIcon(imageName: "rectangle.on.rectangle")
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.tintColor = .label
        cell.textLabel?.text = "Links"
        cell.accessoryType = .disclosureIndicator
        cell.onLayoutSubviews = cell.applyRowStyle
        cell.selectionStyle = .none
        return cell
    }()
    
    let tagCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1, reuseIdentifier: nil)
        cell.imageView?.image = createRowIcon(imageName: "tag")
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.tintColor = .label
        cell.textLabel?.text = "Tags"
        cell.accessoryType = .disclosureIndicator
        cell.onLayoutSubviews = cell.applyRowStyle
        cell.selectionStyle = .none
        return cell
    }()
    
    let noteCell: StaticTableViewCell = {
        let cell = StaticTableViewCell(style: .value1, reuseIdentifier: nil)
        cell.imageView?.image = createRowIcon(imageName: "doc.plaintext")
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.tintColor = .label
        cell.textLabel?.text = "Note"
        cell.accessoryType = .disclosureIndicator
        cell.onLayoutSubviews = cell.applyRowStyle
        cell.selectionStyle = .none
        return cell
    }()
    
    let favoriteActiveImage = createRowIcon(imageName: "star.fill")
    let favoriteInactiveImage = createRowIcon(imageName: "star")
    
    
    // MARK: Constructor
    
    init(viewModel: NoteCardFormModel) {
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
}


// MARK: - Data Source & Delegate

extension NoteCardFormController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowKind = sections[indexPath.section][indexPath.row]
        switch rowKind {
        case .formality: return 35
        case .native, .translation: return 75
        default: return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "NATIVE & TRANSLATION"
        case 1: return "COLLECTION"
        case 2: return "FORMALITY"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowKind = sections[indexPath.section][indexPath.row]
        switch rowKind {
        case .native: return nativeCell
        case .translation: return translationCell
        case .collection: return collectionCell
        case .formality: return formalityCell
        case .favorite: return favoriteCell
        case .relationship: return relationshipCell
        case .tag: return tagCell
        case .note: return noteCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowKind = sections[indexPath.section][indexPath.row]
        
        switch rowKind {
        case .native:
            nativeCell.uiView.textField.becomeFirstResponder()
        
        case .translation:
            translationCell.uiView.textField.becomeFirstResponder()
        
        default:
            tableView.endEditing(true)
        }
        
        onRowSelected?(rowKind)
    }
}


extension NoteCardFormController {
    
    private func setupView() {
        tableView.separatorStyle = .none
        
        for (index, formality) in viewModel.formalities.enumerated() {
            formalityCell.uiView.insertSegment(withTitle: formality, at: index, animated: false)
        }
        
        nativeCell.uiView.textField.returnKeyType = .next
        nativeCell.uiView.textField.delegate = self
        
        translationCell.uiView.textField.returnKeyType = .done
        translationCell.uiView.textField.delegate = self
    }
    
    static func createRowIcon(imageName: String) -> UIImage? {
        let symbol = UIImage.SymbolConfiguration(textStyle: .body)
        let image = UIImage(systemName: imageName, withConfiguration: symbol)
        return image
    }
}


// MARK: Text Field Delegate

extension NoteCardFormController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === nativeCell.uiView.textField {
            translationCell.uiView.textField.becomeFirstResponder()
            return false
        }
        return textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateViewModelNativeTranslation(with: textField)
    }
}


// MARK: - Object Will Change

extension NoteCardFormController {
    
    private func setupViewModelObjectWillChange() {
        let updateNativeTranslation = #selector(updateViewModelNativeTranslation)
        nativeCell.uiView.textField.addTarget(self, action: updateNativeTranslation, for: .editingChanged)
        translationCell.uiView.textField.addTarget(self, action: updateNativeTranslation, for: .editingChanged)
        
        formalityCell.uiView.addTarget(self, action: #selector(handleSegmentControlChanged), for: .valueChanged)
        favoriteCell.toggle!.addTarget(self, action: #selector(handleToggleChanged), for: .valueChanged)
        
        let objectWillChange = viewModel
            .objectWillChange
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.handleViewModelObjectWillChange()
            })
        viewModelSubscribers.append(objectWillChange)
        viewModel.objectWillChange.send()
    }
    
    @objc private func updateViewModelNativeTranslation(with textField: UITextField) {
        switch textField {
        case nativeCell.uiView.textField:
            viewModel.native = textField.text ?? ""
        case translationCell.uiView.textField:
            viewModel.translation = textField.text ?? ""
        default: fatalError("🧨 attempted to handle unknown text field \(textField) 🧨")
        }
    }
    
    @objc private func handleSegmentControlChanged(_ sender: UISegmentedControl) {
        guard sender === formalityCell.uiView else { return }
        viewModel.formality = sender.selectedSegmentIndex
        selectionHaptic.selectionChanged()
        selectionHaptic.prepare()
        tableView.endEditing(true)
    }
    
    @objc private func handleToggleChanged(_ sender: UISwitch) {
        guard sender === favoriteCell.toggle else { return }
        viewModel.isFavorite = sender.isOn
        tableView.endEditing(true)
    }
    
    private func handleViewModelObjectWillChange() {
        nativeCell.uiView.textField.text = viewModel.native
        nativeCell.uiView.textField.placeholder = viewModel.nativePlaceholder
        
        translationCell.uiView.textField.text = viewModel.translation
        translationCell.uiView.textField.placeholder = viewModel.translationPlaceholder
        
        collectionCell.textLabel?.text = viewModel.uiCollectionName
        collectionCell.detailTextLabel?.text = viewModel.uiCollectionCardsCount
        
        let selectedColor = viewModel.selectedFormality.uiColor
        formalityCell.uiView.selectedSegmentIndex = viewModel.formality
        formalityCell.uiView.setTitleTextAttributes([.foregroundColor: selectedColor], for: .selected)
        
        let favoriteImage = viewModel.isFavorite ? favoriteActiveImage : favoriteInactiveImage
        favoriteCell.imageView?.image = favoriteImage
        favoriteCell.toggle!.setOn(viewModel.isFavorite, animated: true)
        
        relationshipCell.detailTextLabel?.text = viewModel.uiRelationshipsCount
        
        tagCell.detailTextLabel?.text = viewModel.uiTagsCount
        
        noteCell.detailTextLabel?.text = viewModel.uiCompactNote
    }
}


// MARK: - Enum

enum NoteCardFormRowKind {
    case native
    case translation
    case collection
    case formality
    case favorite
    case relationship
    case tag
    case note
}


// MARK: - Wrapper

struct NoteCardFormControllerWrapper: UIViewControllerRepresentable {
    
    var viewModel: NoteCardFormModel
    
    var onRowSelected: ((NoteCardFormRowKind) -> Void)?
        
    
    func makeUIViewController(context: Context) -> NoteCardFormController {
        let controller = NoteCardFormController(viewModel: viewModel)
        controller.tableView.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: NoteCardFormController, context: Context) {
        uiViewController.onRowSelected = onRowSelected
    }
}

struct NoteCardViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardFormControllerWrapper(viewModel: .init())
    }
}
