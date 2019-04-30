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
    
    /*
     keep a reference to the context
     */
    /// The source vocabulary's context.
    private let context: NSManagedObjectContext
    
    /// The vocabulary to work on.
    private let sourceVocabulary: Vocabulary
    
    /// All vocabularies in the collection excluding the `sourceVocabulary`.
    private let selectableVocabularies: [Vocabulary]
    
    /// A tracker used to keep track of previous or new connections.
    private(set) var connectionTracker: VocabularyConnectionTracker
    
    private let segmentView = VocabularyConnectionTypeSegmentView(types: VocabularyConnection.ConnectionType.allCases)
    
    var doneCompletion: (() -> Void)?
    var cancelCompletion: (() -> Void)?
    
    
    private let sourceVocabularyIndexPath = IndexPath(item: 0, section: 0)
    
    
    /// - parameters:
    ///   - sourceVocabularyID: The `objectID` of the source vocabulary.
    ///   - context: The context to work on.
    init(sourceVocabularyID: NSManagedObjectID, context: NSManagedObjectContext) {
        // create new context to work on
        self.context = context
        
        // fetching the source vocabulary using the ID and casting it to a Vocabulary
        self.sourceVocabulary = context.object(with: sourceVocabularyID) as! Vocabulary
        
        // instantiate the tracker
        connectionTracker = VocabularyConnectionTracker(vocabulary: sourceVocabulary)
        
        // make all vocabularies selectable except for the sourceVocabulary
        let allVocabualries = sourceVocabulary.collection.vocabularies
        selectableVocabularies = allVocabualries.subtracting([sourceVocabulary]).sorted(by: { $0.translation < $1.translation })
        
        
        
        // for the layout and how the scene is displayed
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
    
    
    @objc private func segmentControlValueChanged(_ sender: UISegmentedControl) {
        #warning("TODO: update UI to highlighted appropriate vocabularies")
        // We want to reload the visible vocabulary cells
        let visibleCellIndexPath = collectionView.indexPathsForVisibleItems
        collectionView.reloadItems(at: visibleCellIndexPath) // reload visible accordingly
    }
    
    func doneBarItemTapped() {
        doneCompletion?()
    }
    
    func cancelBarItemTapped() {
        cancelCompletion?()
    }
}

/*
 displaying all the cells
 */
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
        var isHighlighted = false
        
        // if the index path is 0, reload with the source vocab. else reload with all other vocabulary
        if indexPath == sourceVocabularyIndexPath {
            cell.reloadCell(with: sourceVocabulary)
        } else {
            let selectableVocab = selectableVocabularies[indexPath.item]
            cell.reloadCell(with: selectableVocab)
            isHighlighted = connectionTracker.contains(selectableVocab, for: segmentView.selectedConnectionType)
        }
        cell.setHighlight(isHighlighted, color: nil)

        // disabling the attribute buttons
        guard cell.moreView.button.isUserInteractionEnabled else { return cell }
        for button in cell.allButtons {
            button.isUserInteractionEnabled = false
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath != sourceVocabularyIndexPath else { return }

        #warning("TODO: implement toggle connection")

        // Get the selected vocab
        let selectedVocab = selectableVocabularies[indexPath.item]
        
        // Checking to see if the selected vocab is in the tracker.
        // If the user selected a vocab, track it. If the user selects it again, untrack it.
        if connectionTracker.contains(selectedVocab, for: segmentView.selectedConnectionType) {
            connectionTracker.removeTrackedVocabulary(selectedVocab, connectionType: segmentView.selectedConnectionType)
        } else {
            connectionTracker.trackVocabulary(selectedVocab, connectionType: segmentView.selectedConnectionType)
        }
        
        // Reload the selected cell content based on tracker logic
        collectionView.reloadItems(at: [indexPath])
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
