//
//  HomeSettingView.swift
//  FNote
//
//  Created by Dara Beng on 1/31/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import BDUIKnit
import BDSwiftility


struct HomeSettingView: View {
    
    @ObservedObject var preference: UserPreference
    
    @State private var sheet = BDPresentationItem<Sheet>()
    
    
    var body: some View {
        NavigationView {
            SettingViewControllerWrapper(preference: preference, onRowSelected: handleRowSelected)
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
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .onboardView:
            let done = { self.sheet.dismiss() }
            return OnboardView(viewModel: .init(), alwaysShowXButton: true, onDismiss: done)
                .eraseToAnyView()
        }
    }
    
    func handleRowSelected(_ row: SettingViewController.Row) {
        switch row {
        case .welcome:
            sheet.present(.onboardView)
        
        default: break
        }
    }
}


struct HomeSettingView_Previews: PreviewProvider {
    static let preference = UserPreference.shared
    static var previews: some View {
        Group {
            HomeSettingView(preference: preference).colorScheme(.light)
            HomeSettingView(preference: preference).colorScheme(.dark)
        }
    }
}
