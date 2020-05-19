//
//  HomeSettingView.swift
//  FNote
//
//  Created by Dara Beng on 1/31/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import BDUIKnit


struct HomeSettingView: View {
    
    @ObservedObject var appState: AppState
    
    @State private var sheet = BDPresentationItem<Sheet>()
    
    @State private var archivesViewModel: NoteCardCollectionCollectionViewModel?
    
    
    var body: some View {
        NavigationView {
            SettingViewControllerWrapper(
                preference: appState.preference,
                onRowSelected: handleRowSelected
            )
                .navigationBarTitle("Settings", displayMode: .large)
                .edgesIgnoringSafeArea(.all)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet.current, content: presentationSheet)
    }
}


// MARK: - Sheet & Alert

extension HomeSettingView {
    
    enum Sheet: BDPresentationSheetItem {
        case onboardView
        case archives
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .archives:
            return UserArchivedDataView(collectionViewModel: archivesViewModel!)
                .eraseToAnyView()
        
        case .onboardView:
            return OnboardView(
                viewModel: .init(),
                alwaysShowXButton: true,
                onDismiss: { self.sheet.dismiss() }
            )
                .eraseToAnyView()
        }
    }
    
    func handleRowSelected(_ row: SettingViewController.Row) {
        switch row {
        case .welcome:
            sheet.present(.onboardView)
        
        case .archives:
            let model = NoteCardCollectionCollectionViewModel()
            archivesViewModel = model
            model.collections = appState.fetchV1Collections()
            sheet.present(.archives)
        
        case .appearanceDark, .appearanceLight, .appearanceSystem: break
        case .markdownNoteToggle, .markdownSoftBreakToggle, .generalKeyboardUsage: break
        case .version: break
        }
    }
}


struct HomeSettingView_Previews: PreviewProvider {
    static let appState = AppState(parentContext: .sample)
    static var previews: some View {
        Group {
            HomeSettingView(appState: appState).colorScheme(.light)
            HomeSettingView(appState: appState).colorScheme(.dark)
        }
    }
}
