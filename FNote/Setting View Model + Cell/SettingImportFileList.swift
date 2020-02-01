//
//  SettingImportFileList.swift
//  FNote
//
//  Created by Dara Beng on 1/31/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct SettingImportFileList: View {
    
    var files: [URL]
    
    var onFileSelected: ((URL) -> Void)?
    
    @State private var fileToShare: [URL] = []
    @State private var showActivitySheet = false
    
    @State private var showConfirmSelectionAlert = false
    @State private var selectedFile: URL?
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 12) {
                ForEach(files, id: \.self) { file in
                    ImportFileRow(
                        fileName: self.fileName(for: file),
                        onShare: { self.beginActivitySheet(for: file) }
                    )
                        .onTapGesture(perform: { self.confirmSelection(file: file) })
                }
            }
            .padding(.vertical, 12)
        }
        .sheet(isPresented: $showActivitySheet, content: activitySheet)
        .alert(isPresented: $showConfirmSelectionAlert, content: confirmSelectionAlert)
    }
}


// MARK: - Action

extension SettingImportFileList {
    
    func activitySheet() -> some View {
        ActivityViewControllerWrapper(items: fileToShare)
    }
    
    func beginActivitySheet(for file: URL) {
        fileToShare = [file]
        showActivitySheet = true
    }
    
    func confirmSelectionAlert() -> Alert {
        guard let file = selectedFile else {
            fatalError("🧨 attempt to show alert without a file 🧨")
        }
        let title = Text("Import Data")
        let message = Text("This will override the current data with\n'\(fileName(for: file))'")
        let cancel = Alert.Button.cancel(cancelSelection)
        let commit = Alert.Button.destructive(Text("Override"), action: commitSelection)
        return Alert(title: title, message: message, primaryButton: cancel, secondaryButton: commit)
    }
    
    func confirmSelection(file: URL) {
        selectedFile = file
        showConfirmSelectionAlert = true
    }
    
    func cancelSelection() {
        selectedFile = nil
        showConfirmSelectionAlert = false
    }
    
    func commitSelection() {
        guard let file = selectedFile else { return }
        onFileSelected?(file)
    }
    
    func fileName(for file: URL) -> String {
        file.lastPathComponent.replacingOccurrences(of: ".\(file.pathExtension)", with: "")
    }
}


// MARK: - Row

struct ImportFileRow: View {
    
    var fileName: String
    
    var onShare: (() -> Void)?
    
    
    var body: some View {
        HStack {
            Text(fileName)
                .lineLimit(1)
            Spacer()
            Button(action: onShare ?? {}) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.primary)
                    .imageScale(.large)
                    .offset(y: -3)
                    .frame(width: 50, height: 50, alignment: .center)
            }
        }
        .padding(.leading)
        .frame(height: 50)
        .background(Color.noteCardBackground)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
