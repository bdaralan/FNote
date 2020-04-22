//
//  PublicUserView.swift
//  FNote
//
//  Created by Dara Beng on 4/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import BDUIKnit
import BDSwiftility


struct PublicUserView: View {
    
    @ObservedObject var viewModel: PublicUserViewModel
    
    @State private var sheet = BDPresentationItem<Sheet>()
    @State private var textFieldModel = BDModalTextFieldModel()
    @State private var textViewModel = BDModalTextViewModel()

    
    var body: some View {
        NavigationView {
            PublicUserViewControllerWrapper(viewModel: viewModel, onRowSelected: handleRowSelected)
                .navigationBarTitle("Profile", displayMode: .inline)
                .navigationBarItems(leading: cancelNavItem, trailing: trailingNavItems)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet.current, content: presentationSheet)
        .disabled(viewModel.disableUserInteraction)
    }
}


extension PublicUserView {
    
    var cancelNavItem: some View {
        Button("Cancel") {
            let user = self.viewModel.user
            self.viewModel.update(with: user)
        }
        .opacity(viewModel.hasChanges ? 1 : 0)
    }
    
    var updateNavItem: some View {
        let label = { Text("Update").bold() }
        let action = {
            self.viewModel.disableUserInteraction = true
            self.viewModel.saveChanges()
        }
        return Button(action: action, label: label)
    }
    
    var doneNavItem: some View {
        let label = { Text("Done").bold() }
        let action = viewModel.onDone ?? {}
        return Button(action: action, label: label)
    }
    
    var trailingNavItems: some View {
        if viewModel.hasChanges {
            return updateNavItem.eraseToAnyView()
        } else {
            return doneNavItem.eraseToAnyView()
        }
    }
    
    var usernameSectionHeader: some View  {
        Text("USERNAME").padding(.top, 24)
    }
    
    var userBioSectionHeader: some View {
        Text("BIO")
    }
}


extension PublicUserView {
    
    enum Sheet: BDPresentationSheetItem {
        case textField
        case textView
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .textField:
            return BDModalTextField(viewModel: $textFieldModel)
                .eraseToAnyView()
        case .textView:
            return BDModalTextView(viewModel: $textViewModel)
                .eraseToAnyView()
        }
    }
    
    func handleRowSelected(_ row: PublicUserViewController.Row) {
        switch row {
        case .username: beginEditUsername()
        case .userBio: beginEditUserBio()
        }
    }
    
    func beginEditUsername() {
        textFieldModel = .init()
        textFieldModel.title = "Username"
        textFieldModel.text = viewModel.username
        textFieldModel.prompt = "Username can contain (A-Z, 0-9, -, _)"
        
        let placeholder = viewModel.username.isEmpty ? "username" : viewModel.username
        textFieldModel.placeholder = placeholder
        
        textFieldModel.configure = { textField in
            textField.autocapitalizationType = .none
        }
        
        textFieldModel.onCancel = {
            self.textFieldModel.isFirstResponder = false
            self.sheet.dismiss()
        }
        
        textFieldModel.onReturnKey = {
            defer {
                self.textFieldModel.isFirstResponder = false
                self.sheet.dismiss()
            }
            let username = self.textFieldModel.text.trimmedUsername()
            guard username.isEmpty == false else { return }
            self.viewModel.username = username
        }
        
        textFieldModel.isFirstResponder = true
        sheet.present(.textField)
    }
    
    func beginEditUserBio() {
        textViewModel = .init()
        textViewModel.title = "About"
        textViewModel.text = viewModel.userBio
        
        textViewModel.onCommit = {
            let bio = self.textViewModel.text.trimmed()
            self.viewModel.userBio = bio
            self.textViewModel.isFirstResponder = false
            self.sheet.dismiss()
        }
        
        textViewModel.isFirstResponder = true
        sheet.present(.textView)
    }
}


struct PublicUserView_Previews: PreviewProvider {
    static let viewModel: PublicUserViewModel = {
        let user = PublicUser(userID: "id", username: "DLan", about: "Hello, this is Lan.")
        let model = PublicUserViewModel(user: user)
        model.onDone = {}
        return model
    }()
    static var previews: some View {
        Group {
            PublicUserView(viewModel: viewModel)
            PublicUserView(viewModel: viewModel).environment(\.colorScheme, .dark)
            PublicUserView(viewModel: viewModel)
                .previewLayout(.fixed(width: 400, height: 400))
        }
    }
}


