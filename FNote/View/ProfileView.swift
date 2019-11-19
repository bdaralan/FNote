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
    @State private var usernameToChange = ""
    @State private var showModalTextField = false
    @ObservedObject var setting = UserSetting.current
    
    
    // MARK: Body
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .center, spacing: 16) {
                    // start user profile picture
                    Image("usethis").resizable().aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                        .overlay(Circle().stroke(Color.black, lineWidth: 5))
                    
                    HStack {
                    // grab username
                        Text(setting.username).font(.headline)
                    Image(systemName: "pencil").onTapGesture(perform: beginUsername)
                    }
                }
            .padding()
                
                Form {
                    Section {
                        Text("Favorite cards.")
                    }
                    
                    Section {
                        Text("Dark Mode toggle")
                    }
                    
                    Section {
                        Text("Help")
                    }
                } // end form
                    .overlay(Text(showVersion()).foregroundColor(.secondary), alignment: .bottom)

            } // end vstack
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
        .navigationBarTitle("Profile")
        .sheet(isPresented: $showModalTextField, content: modalTextField) /* place sheet */
        }
    }
}

extension ProfileView {
    // show current version number
    func showVersion() -> String {
        let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return "Version \(appVersionString)"
    }
    
    // modalTextField
    func modalTextField() -> some View {
        return ModalTextField(
            isActive: $showModalTextField,
            text: $usernameToChange,
            prompt: "Enter a new username",
            placeholder: setting.username,
            descriptionColor: .red,
            onCommit: commitUsername
        )
    }
    
    func beginUsername() {
        usernameToChange = ""
        showModalTextField = true
    }
    
    func commitUsername() {
        if usernameToChange.trimmed().isEmpty {
            showModalTextField = false
        }
        
        setting.username = usernameToChange
        showModalTextField = false
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
