//
//  NavigationStateHandler.swift
//  FNote
//
//  Created by Dara Beng on 9/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


/// A state model used to perform actions when a view is pushed to or popped from the NavigationView
///
/// Code Example:
///
///     struct DetailRow: View {
///
///         @ObservedObject var navigationHandler = NavigationStateHandler()
///
///
///         var body: some View {
///             NavigationLink(destination: detailView, isActive: $navigationHandler.isPushed) {
///                 Text("View Detials")
///             }
///         }
///
///         var detailView: some View {
///             Text("Details").onAppear {
///                 self.navigationHandler.onPushed = { /* prepare data */ }
///                 self.navigationHandler.onPopped = { /* discard unsaved changes */ }
///             }
///         }
///     }
///
class NavigationStateHandler: ObservableObject {
    
    /// A flag to bind with `NavigationLink.isActive`.
    @Published var isPushed = false {
        didSet { state = isPushed ? .pushed : .popped }
    }
    
    /// The state of the navigation.
    private var state: State? = .none {
        didSet {
            switch state {
            case .pushed: onPushed?()
            case .popped: onPopped?()
            case .none: break
            }
        }
    }
    
    /// An action to perform when pushed.
    var onPushed: (() -> Void)?
    
    /// An action to perform when poped.
    var onPopped: (() -> Void)?
    
    func pop() {
        isPushed = false
    }
}


private extension NavigationStateHandler {
    
    enum State {
        case pushed
        case popped
    }
}
