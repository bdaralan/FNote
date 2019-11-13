//
//  ProfileView.swift
//  FNote
//
//  Created by Dara Beng on 9/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var noteCardCollectionDataSource: NoteCardCollectionDataSource
    
    @EnvironmentObject var tagDataSource: TagDataSource
    
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
                    
                    // grab username
                    Text("Username")
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
            
        }
    }
}

extension ProfileView {
    // show version number
    func showVersion() -> String {
        let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return "Version \(appVersionString)"
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
