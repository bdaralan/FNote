//
//  HomeView.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import BDUIKnit


struct HomeView: View {
    
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var userPreference: UserPreference
    
    @State private var currentTab = Tab.card
    
    @State private var sheet = BDPresentationItem<Sheet>()
    
    @State private var publicCollectionViewModel = CommunityViewModel.placeholder
    @State private var cardCollectionViewModel = NoteCardCollectionViewModel()
    @State private var tagCollectionViewModel = TagCollectionViewModel()
    
    @State private var onboardViewModel: OnboardCollectionViewModel?
    
    let storeRemoteChange = NotificationCenter.default.publisher(for: .persistentStoreRemoteChange)
    
    
    var body: some View {
        TabView(selection: $currentTab) {
            // MARK: Card Tab
            HomeNoteCardView(viewModel: cardCollectionViewModel)
                .tabItem(Tab.card.tabItem)
                .tag(Tab.card)
            
            // MARK: Tag Tab
            HomeTagView(viewModel: tagCollectionViewModel)
                .tabItem(Tab.tag.tabItem)
                .tag(Tab.tag)
            
            HomeCommunityView(viewModel: publicCollectionViewModel)
                .tabItem(Tab.community.tabItem)
                .tag(Tab.community)
            
            // MARK: Setting Tab
            HomeSettingView(preference: .shared)
                .tabItem(Tab.setting.tabItem)
                .tag(Tab.setting)
            
        }
        .onAppear(perform: setupOnAppear)
        .sheet(item: $sheet.current, onDismiss: handleSheetDismissed, content: presentationSheet)
        .disabled(!appState.iCloudActive)
        .onReceive([currentTab].publisher.last(), perform: handleOnReceiveCurrentTab)
        .onReceive(storeRemoteChange.receive(on: DispatchQueue.main), perform: handleStoreRemoteChangeNotification)
    }
}


// MARK: - On Appear

extension HomeView {
    
    func setupOnAppear() {
        showOnboardIfNeeded()
    }
    
    func handleOnReceiveCurrentTab(_ tab: Tab) {
        cardCollectionViewModel.cancelSearch()
    }
    
    func showOnboardIfNeeded() {
        guard AppCache.shouldShowOnboard else { return }
        onboardViewModel = .init()
        sheet.present(.onboard)
    }
    
    func dismissOnboard() {
        AppCache.shouldShowOnboard = false
        sheet.dismiss()
    }
}


extension HomeView {
    
    enum Sheet: BDPresentationSheetItem {
        case onboard
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        
        case .onboard:
            return OnboardView(viewModel: onboardViewModel!, onDismiss: dismissOnboard)
                .eraseToAnyView()
        }
    }
    
    func handleSheetDismissed() {
        dismissOnboard()
    }
}


// MARK: - Remote Changes

extension HomeView {
    
    func handleStoreRemoteChangeNotification(_ notification: Notification) {
        let coreDataStack = CoreDataStack.current
        let history = coreDataStack.historyTracker
        
        // check if need to update token
        guard let newHistoryToken = history.token(fromRemoteChange: notification) else { return }
        guard !newHistoryToken.isEqual(history.lastToken) else { return }
        
        // update token
        history.updateLastToken(newHistoryToken)
        
        // update UI if remote changed
        DispatchQueue.global(qos: .default).async {
            self.refetchObjects()
            DispatchQueue.main.async {
                self.refreshUIs()
            }
        }
    }
    
    func refetchObjects() {
        appState.fetchCurrentNoteCards()
        appState.fetchCollections()
        appState.fetchTags()
    }
    
    func refreshUIs() {
        // case where other device delete the current collection
        if let collection = appState.currentCollection, !appState.collections.contains(collection) {
            appState.setCurrentCollection(nil)
        }
        
        tagCollectionViewModel.tags = appState.tags
        cardCollectionViewModel.noteCards = appState.currentNoteCards
        
        switch currentTab {
        case .setting, .community: break
            
        case .tag:
            tagCollectionViewModel.updateSnapshot(animated: true)
            
        case .card:
            if appState.currentCollection == nil {
                cardCollectionViewModel.updateSnapshot(animated: true)
            } else {
                if !cardCollectionViewModel.isSearchActive {
                    cardCollectionViewModel.updateSnapshot(animated: true)
                }
            }
        }
    }
}


// MARK: - Tab Enum

extension HomeView {
    
    enum Tab: Int {
        case card
        case tag
        case setting
        case community
        
        
        var title: String {
            switch self {
            case .card: return "Cards"
            case .tag: return "Tags"
            case .setting: return "Settings"
            case .community: return "Communities"
            }
        }
        
        var systemImage: String {
            switch self {
            case .card: return "rectangle.fill.on.rectangle.angled.fill"
            case .tag: return "tag.fill"
            case .setting: return "gear"
            case .community: return "person.3.fill"
            }
        }
        
        func tabItem() -> some View {
            let size: CGFloat = self == .setting ? 23 : 17
            
            let image = Image(systemName: systemImage)
                .frame(alignment: .bottom)
                .font(.system(size: size))
            
            let tabName = Text(title)
            
            return ViewBuilder.buildBlock(image, tabName)
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static let appState = AppState(parentContext: .sample)
    static let userPreference = UserPreference.shared
    static var previews: some View {
        HomeView()
            .environmentObject(appState)
            .environmentObject(userPreference)
            .environment(\.managedObjectContext, appState.parentContext)
    }
}
