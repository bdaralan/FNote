//
//  ProfileView.swift
//  FNote
//
//  Created by Brittney Witts on 11/13/19.
//  Copyright © 2019 Brittney Witts. All rights reserved.
//

import SwiftUI


struct ProfileView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var context
    
    @ObservedObject var setting: UserSetting
    
    @State private var usernameToChange = ""
    @State private var isModalTextFieldActive = false
    @State private var sheet: Sheet?
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    @FetchRequest(fetchRequest: NoteCard.requestFavoriteCards())
    var favoriteNoteCardResults
    
    
    // MARK: Body
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                profilePictureView
                Divider()
                List {
                    favoriteCardSection
                    colorSchemeSection
                    helpSection
                }
                .listStyle(GroupedListStyle())
            }
            .navigationBarHidden(true) /* hide the nav bar */
            .navigationBarTitle("") /* SwiftUI bug: must set the title to something to hide the nav bar */
            .sheet(item: $sheet, onDismiss: dismissPresentationSheet, content: presentationSheet)
        }
    }
}


// MARK: - User Profile

extension ProfileView {
    
    var profilePictureView: some View {
        VStack(alignment: .center, spacing: 16) {
            // start user profile picture
            Image("user-profile-placeholder")
                .resizable()
                .frame(width: 100, height: 100)
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
                .shadow(radius: 10)
                .overlay(Circle().stroke(colorScheme == .dark ? Color.white : .black, lineWidth: 2))
            
            // grab username
            Text(setting.username)
                .font(.headline)
                .overlay(editPencil, alignment: .trailing)
        }
        .padding()
    }
    
    // set the pencil image to be able to edit the username
    var editPencil: some View {
        Button(action: beginEditingUsername) {
            Image(systemName: "pencil")
                .font(Font.body.weight(.semibold))
        }
        .offset(x: 25)
    }
}


// MARK: - Setting Section

extension ProfileView {
    
    // MARK: Favorite Cards
    var favoriteCardSection: some View {
        Section {
            Button("Favorite Cards", action: showFavoriteCardSheet)
                .accentColor(.primary)
        }
    }
    
    var favoriteCardSheet: some View {
        let doneNavItem = Button("Done", action: dismissPresentationSheet)
        return NavigationView {
            NoteCardScrollView(
                noteCards: Array(favoriteNoteCardResults),
                selectedCards: [],
                showQuickButtons: false,
                searchContext: context,
                onTap: handleFavoriteNoteCardTapped
            )
                .navigationBarTitle("Favorite Cards", displayMode: .inline)
                .navigationBarItems(leading: doneNavItem)
        }
    }
    
    func showFavoriteCardSheet() {
        sheet = .favoriteCard
    }
    
    func dismissFavoriteCardSheet() {
        sheet = nil
    }
    
    func handleFavoriteNoteCardTapped(_ noteCard: NoteCard) {
        dismissFavoriteCardSheet()
        NotificationCenter.default.post(name: .requestDisplayingNoteCard, object: noteCard)
    }
    
    // MARK: Color Schemes
    var colorSchemeSection: some View {
        Section(header: Text("APPEARANCE")) {
            createColorSchemeButton(action: { self.setColorScheme(to: .system) }, colorScheme: .system)
            createColorSchemeButton(action: { self.setColorScheme(to: .alwaysLight) }, colorScheme: .alwaysLight)
            createColorSchemeButton(action: { self.setColorScheme(to: .alwaysDark) }, colorScheme: .alwaysDark)
        }
    }
    
    func setColorScheme(to colorScheme: UserSetting.ColorScheme) {
        setting.colorScheme = colorScheme
        setting.save()
    }
    
    func createColorSchemeButton (action: @escaping () -> Void, colorScheme: UserSetting.ColorScheme) -> some View {
        Button(action: action) {
            HStack {
                Text(colorScheme.title)
                if self.setting.colorScheme == colorScheme {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
            .accentColor(.primary)
        }
    }
    
    // MARK: Help
    var helpSection: some View {
        Section(footer: appVersionFooterText) {
            Text("Help")
        }
    }
    
    var appVersionFooterText: some View {
        // if cannot get the version, show nothing (empty text)
        let key = "CFBundleShortVersionString"
        let version = Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
        let appVersion = version.isEmpty ? "" : "Version \(version)"
        return Text(appVersion)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }
}


// MARK: - Editing Username Sheet
extension ProfileView {
    
    var editUsernameSheet: some View {
        ModalTextField(
            text: $usernameToChange,
            isFirstResponder: $isModalTextFieldActive,
            prompt: "Edit Username",
            placeholder: setting.username,
            onCancel: cancelEditingUsername,
            onCommit: commitEditingUsername
        )
    }
    
    func beginEditingUsername() {
        usernameToChange = setting.username
        isModalTextFieldActive = true
        sheet = .editUsername
    }
    
    func cancelEditingUsername() {
        isModalTextFieldActive = false
        sheet = nil
    }
    
    func commitEditingUsername() {
        let newUsername = usernameToChange.trimmed()
        if !newUsername.isEmpty, setting.username != newUsername {
            setting.username = newUsername
            setting.save()
        }
        isModalTextFieldActive = false
        sheet = nil
    }
}


// MARK: - Sheet

extension ProfileView {
    
    enum Sheet: Identifiable {
        case favoriteCard
        case editUsername
        
        var id: Sheet { self }
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .editUsername:
            return editUsernameSheet.eraseToAnyView()
        case .favoriteCard:
            return favoriteCardSheet.eraseToAnyView()
        }
    }
    
    func dismissPresentationSheet() {
        dismissFavoriteCardSheet()
        cancelEditingUsername()
    }
}


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(setting: .sample)
    }
}
