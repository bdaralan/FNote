//
//  VocabularyConnectionTracker.swift
//  FNote
//
//  Created by Dara Beng on 4/23/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


class VocabularyConnectionTracker {
    
    /// The source vocabulary that the tracker is tracking all connections for.
    private(set) var vocabulary: Vocabulary
    
    /// A dictionary that keeping tracks of previous and new connected vocabularies.
    ///
    /// The vocabularies are tracked and grouped by the connection type.
    /// - Dictionary Key is the connection type.
    /// - Dictionary Value is a set of tracked vocabularies.
    private(set) var trackerDictionary = [VocabularyConnection.ConnectionType: Set<Vocabulary>]()
    
    
    init(vocabulary: Vocabulary) {
        self.vocabulary = vocabulary
        
        // assign an empty set as the initial value
        for connectionType in VocabularyConnection.ConnectionType.allCases {
            trackerDictionary[connectionType] = []
        }
        
        // fill in the tracker with already connected vocabularies if any
        for connection in vocabulary.connections {
            let connectedVocabualry = connection.source == vocabulary ? connection.target : connection.source
            trackVocabulary(connectedVocabualry, connectionType: connection.type)
        }
    }
    
    
    /// Add vocabulary to the tracker.
    /// - Parameters:
    ///   - vocabulary: The vocabulary to be tracked.
    ///   - connectionType: The connection type for vocabulary to be tracked.
    func trackVocabulary(_ vocabulary: Vocabulary, connectionType: VocabularyConnection.ConnectionType) {
        trackerDictionary[connectionType]?.insert(vocabulary)
    }
    
    /// Remove vocabulary from the tracker.
    ///
    /// - Parameters:
    ///   - vocabulary: The vocabulary to be removed.
    ///   - connectionType: The connection type for the tracked vocabulary.
    func removeTrackedVocabulary(_ vocabulary: Vocabulary, connectionType: VocabularyConnection.ConnectionType) {
        trackerDictionary[connectionType]?.remove(vocabulary)
    }
    
    /// Get tracked vocabularies.
    /// - Parameter connectionType: The connection type in question.
    /// - Returns: A set of tracked vocabularies or empty if there is none.
    func trackedVocabularies(for connectionType: VocabularyConnection.ConnectionType) -> Set<Vocabulary> {
        return trackerDictionary[connectionType] ?? []
    }
    
    /// Check if a vocabulary is already tracked by the tracker.
    /// - Parameters:
    ///   - vocabulary: The vocabulary to check.
    ///   - connectionType: The connection type to check.
    func hasTrackedVocabulary(_ vocabulary: Vocabulary, for connectionType: VocabularyConnection.ConnectionType) -> Bool {
        return trackerDictionary[connectionType]?.contains(vocabulary) ?? false
    }
}
