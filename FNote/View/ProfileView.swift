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
                    Image("usethis").resizable().aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                        .overlay(Circle().stroke(Color.black, lineWidth: 5))
                    
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
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
        .navigationBarTitle("Profile")
       
        }
    }
}

extension ProfileView {
    // add version number to the bottom of the view

}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
