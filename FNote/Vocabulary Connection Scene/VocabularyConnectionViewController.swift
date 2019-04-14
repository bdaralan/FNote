//
//  VocabularyConnectionViewController.swift
//  FNote
//
//  Created by Dara Beng on 4/5/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit
import CoreData


class VocabularyConnectionViewController: UICollectionViewController, NavigationItemToggleable {
    
    /// The source vocabulary's context.
    private let context: NSManagedObjectContext
    
    /// The vocabulary to work on.
    private let sourceVocabulary: Vocabulary
    
    /// All vocabularies in the collection excluding the `sourceVocabulary`.
    private let selectableVocabularies: [Vocabulary]
    
    /// A dictionary of selected vocabularies based on the connection type.
    private(set) var selectedVocabulariesByType = [VocabularyConnection.ConnectionType: [Vocabulary]]()
    
    private let segmentView = VocabularyConnectionTypeSegmentView(types: VocabularyConnection.ConnectionType.allCases)
    
    var doneCompletion: (() -> Void)?
    var cancelCompletion: (() -> Void)?
    
    private let sourceVocabularyIndexPath = IndexPath(item: 0, section: 0)
    
    
    /// - parameters:
    ///   - sourceVocabularyID: The `objectID` of the source vocabulary.
    ///   - context: The context to work on.
    init(sourceVocabularyID: NSManagedObjectID, context: NSManagedObjectContext) {
        self.context = context
        self.sourceVocabulary = context.object(with: sourceVocabularyID) as! Vocabulary
        
        for connectionType in segmentView.connectionTypes {
            selectedVocabulariesByType[connectionType] = sourceVocabulary.connectedVocabularies(for: connectionType)
        }
        let allVocabualries = sourceVocabulary.collection.vocabularies
        selectableVocabularies = allVocabualries.subtracting([sourceVocabulary]).sorted(by: { $0.translation < $1.translation })
        
        let layout = VocabularyCollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: 0, height: 35)
        layout.sectionHeadersPinToVisibleBounds = true
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }
    
    
    @objc private func segmentControlValueChanged(_ sender: VocabularyConnectionTypeSegmentView) {
        #warning("TODO: update UI to highlighted appropriate vocabularies")
    }
    
    func doneBarItemTapped() {
        doneCompletion?()
    }
    
    func cancelBarItemTapped() {
        cancelCompletion?()
    }
}


extension VocabularyConnectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sourceVocabularyIndexPath.section == section ? 1 : selectableVocabularies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let kind = UICollectionView.elementKindSectionHeader
        let header = collectionView.dequeueRegisteredSupplementaryView(CollectionViewSectionHeader.self, kind: kind, indexPath: indexPath)
        header.titleLabel.text = sourceVocabularyIndexPath == indexPath ? "Vocabulary" : "Connections"
        
        #warning("TODO: need colors for the final version")
        header.backgroundColor = .gray
        header.titleLabel.textColor = .white
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueRegisteredCell(VocabularyCollectionCell.self, for: indexPath)
        #warning("TODO: disable user interaction for vocabulary attribute buttons")
        #warning("TODO: implement highlight cell")
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath != sourceVocabularyIndexPath else { return }
        #warning("TODO: implement toggle connection")
    }
}


extension VocabularyConnectionViewController {
    
    private func setupController() {
        collectionView.registerCell(VocabularyCollectionCell.self)
        collectionView.registerSupplementaryView(CollectionViewSectionHeader.self, kind: UICollectionView.elementKindSectionHeader)
        collectionView.backgroundColor = .offWhiteBackground
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset.top = 44
        
        segmentView.backgroundColor = collectionView.backgroundColor
        segmentView.segmentControl.addTarget(self, action: #selector(segmentControlValueChanged), for: .valueChanged)
        
        view.addSubviews([segmentView])
        let safeArea = view.safeAreaLayoutGuide
        let constaints = [
            segmentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            segmentView.heightAnchor.constraint(equalToConstant: collectionView.contentInset.top)
        ]
        NSLayoutConstraint.activate(constaints)
    }
}
