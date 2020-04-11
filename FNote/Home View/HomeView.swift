//
//  HomeView.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct HomeView: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userPreference: UserPreference
    
    @State private var currentTab = Tab.card
    
    @State private var sheet: Sheet?
    @State private var modalTextFieldModel = ModalTextFieldModel()
    
    @State private var publicCollectionViewModel = PublicCollectionViewModel.placeholder
    @State private var cardCollectionViewModel = NoteCardCollectionViewModel()
    @State private var tagCollectionViewModel = TagCollectionViewModel()
    
    @State private var onboardViewModel: OnboardCollectionViewModel?
    
    @State private var storeRemoteChangeObserver = NotificationObserver(name: .persistentStoreRemoteChange)
    
    
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
        .sheet(item: $sheet, onDismiss: handleSheetDismissed, content: presentationSheet)
        .alert(isPresented: $appState.showDidCopyFileAlert, content: { .DidCopyFileAlert(fileName: appState.copiedFileName) })
        .disabled(!appState.iCloudActive)
        .onReceive([currentTab].publisher.last(), perform: handleOnReceiveCurrentTab)
    }
}


// MARK: - On Appear

extension HomeView {
    
    func setupOnAppear() {
        storeRemoteChangeObserver.onReceived = handleStoreRemoteChangeNotification
        showOnboardIfNeeded()
    }
    
    func handleOnReceiveCurrentTab(_ tab: Tab) {
        cardCollectionViewModel.cancelSearch()
    }
    
    func showOnboardIfNeeded() {
        guard AppCache.shouldShowOnboard else { return }
        onboardViewModel = .init()
        sheet = .onboard
    }
    
    func dismissOnboard() {
        AppCache.shouldShowOnboard = false
        sheet = nil
    }
}


extension HomeView {
    
    enum Sheet: Identifiable {
        var id: Self { self }
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
                self.updateModels()
                self.refreshUIs()
            }
        }
    }
    
    func refetchObjects() {
        appState.fetchCurrentNoteCards()
        appState.fetchCollections()
        appState.fetchTags()
    }
    
    func updateModels() {
        cardCollectionViewModel.noteCards = appState.currentNoteCards
        tagCollectionViewModel.tags = appState.tags
    }
    
    func refreshUIs() {
        switch currentTab {
            
        case .tag:
            tagCollectionViewModel.updateSnapshot(animated: true)
            
        case .setting, .community:
            break
            
        case .card:
            if appState.currentCollection != nil, !cardCollectionViewModel.isSearchActive {
                cardCollectionViewModel.updateSnapshot(animated: true)
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
