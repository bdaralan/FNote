//
//  ProfileView.swift
//  FNote
//
//  Created by Brittney Witts on 11/13/19.
//  Copyright © 2019 Brittney Witts. All rights reserved.
//

import SwiftUI


struct ProfileView: View {
    
    @EnvironmentObject var noteCardCollectionDataSource: NoteCardCollectionDataSource
    @EnvironmentObject var tagDataSource: TagDataSource
    @ObservedObject var setting: UserSetting
    @State private var usernameToChange = ""
    @State private var showModalTextField = false
    @State private var isModalTextFieldActive = false
    
    
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
            .sheet(isPresented: $showModalTextField, content: modalTextField) /* place sheet */
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
                .overlay(Circle().stroke(Color.black, lineWidth: 2))
            
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
    
    // FAVORITE CARDS
    var favoriteCardSection: some View {
        Section {
            Text("Favorite cards.")
        }
    }
    
    // COLOR SCHEMES
    var colorSchemeSection: some View {
        Section(header: Text("COLOR SCHEMES")) {
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
    
    // HELP SECTION
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


// MARK: - Sheet

extension ProfileView {
    
    // modalTextField
    func modalTextField() -> some View {
        ModalTextField(
            isActive: $isModalTextFieldActive,
            text: $usernameToChange,
            prompt: "Edit Username",
            placeholder: setting.username,
            onCancel: cancelEditingUsername,
            onCommit: commitEditingUsername
        )
    }
    
    func beginEditingUsername() {
        usernameToChange = setting.username
        isModalTextFieldActive = true
        showModalTextField = true
    }
    
    func cancelEditingUsername() {
        isModalTextFieldActive = false
        showModalTextField = false
    }
    
    func commitEditingUsername() {
        let newUsername = usernameToChange.trimmed()
        if !newUsername.isEmpty, setting.username != newUsername {
            setting.username = newUsername
            setting.save()
        }
        isModalTextFieldActive = false
        showModalTextField = false
    }
}


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(setting: .sample)
    }
}
