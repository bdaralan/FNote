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
    @State private var presenterViewModel: NoteCardDetailPresenterModel?
    
    @State private var archivesAlert: Alert?
    @State private var showArchiesAlert = false
    
    
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
        .sheet(item: $sheet.current, onDismiss: sheetDismissed, content: presentationSheet)
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
            return UserArchivedDataView(
                collectionViewModel: archivesViewModel!,
                onDone: { self.sheet.dismiss() }
            )
                .overlay(NoteCardDetailPresenter(viewModel: presenterViewModel!))
                .alert(isPresented: $showArchiesAlert, content: { self.archivesAlert! })
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
    
    func sheetDismissed() {
        archivesViewModel = nil
    }
    
    func handleRowSelected(_ row: SettingViewController.Row) {
        switch row {
        case .welcome:
            sheet.present(.onboardView)
        
        case .archives:
            setupArchivesViewModel()
            sheet.present(.archives)
        
        case .appearanceDark, .appearanceLight, .appearanceSystem: break
        case .markdownNoteToggle, .markdownSoftBreakToggle, .generalKeyboardUsage: break
        case .version: break
        }
    }
    
    func setupArchivesViewModel() {
        archivesViewModel = .init()
        presenterViewModel = .init(appState: appState)
        
        let archivesModel = archivesViewModel!
        let presenterModel = presenterViewModel!
        
        archivesModel.collections = appState.fetchV1Collections()
        archivesModel.contextMenus = [.delete, .importData]
        
        archivesModel.onContextMenuSelected = { menu, collection in
            switch menu {
            case .delete:
                self.beginDelete(archivedCollection: collection)
            case .importData:
                self.beginImport(archivedCollection: collection)
            default:
                fatalError("🧨 context menu \(menu) is not setup here 🧨")
            }
        }
        
        archivesModel.onCollectionSelected = { collection in
            let noteCards = collection.noteCards.sorted(by: { $0.translation < $1.translation })
            presenterModel.sheet = .noteCards(noteCards, title: collection.name)
        }
    }
    
    func beginDelete(archivedCollection: NoteCardCollection) {
        guard let archivesModel = archivesViewModel else {
            fatalError("🧨 call beginDeleteArchived without setup archivesViewModel 🧨")
        }
        archivesAlert = Alert.DeleteNoteCardCollection(archivedCollection, onCancel: nil) {
            self.appState.objectWillChange.send()
            archivesModel.collections.removeAll(where: { $0 === archivedCollection })
            archivesModel.updateSnapshot(animated: true)
            let modifier = ObjectModifier(.update(archivedCollection))
            modifier.delete()
            modifier.save()
        }
        showArchiesAlert = true
    }
    
    func beginImport(archivedCollection: NoteCardCollection) {
        guard let archivesModel = archivesViewModel else {
            fatalError("🧨 call beginDeleteArchived without setup archivesViewModel 🧨")
        }
        let importContext = appState.parentContext.newChildContext()
        let collections = [archivedCollection]
        ObjectMaker.importV1Collections(collections, using: importContext, prefix: "[imported] ")
        importContext.quickSave()
        archivesModel.selectedCollectionIDs.insert(archivedCollection.uuid)
        archivesModel.reloadVisibleCells()
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
