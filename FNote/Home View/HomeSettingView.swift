//
//  HomeSettingView.swift
//  FNote
//
//  Created by Dara Beng on 1/31/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct HomeSettingView: View {
    
    @ObservedObject var userPreference: UserPreference
    
    @State private var sheet: Sheet?
    @State private var textFieldModel = ModalTextFieldModel()
    
    var useMarkdown: Binding<Bool> {
        .init(
            get: { self.userPreference.useMarkdown },
            set: { self.userPreference.objectWillChange.send(); self.userPreference.useMarkdown = $0 }
        )
    }
    
    var useMarkdownSoftBreak: Binding<Bool> {
        .init(
            get: { self.userPreference.useMarkdownSoftBreak },
            set: { self.userPreference.objectWillChange.send(); self.userPreference.useMarkdownSoftBreak = $0 }
        )
    }
    
    var checkedSystem: Bool {
        userPreference.colorScheme == UserPreference.ColorScheme.system.rawValue
    }
    
    var checkedLight: Bool {
        userPreference.colorScheme == UserPreference.ColorScheme.light.rawValue
    }
    
    var checkedDark: Bool {
        userPreference.colorScheme == UserPreference.ColorScheme.dark.rawValue
    }
    
    var appVersionNumber: String {
        let key = "CFBundleShortVersionString"
        let version = Bundle.main.object(forInfoDictionaryKey: key) as? String ?? "???"
        return version
    }
    
    var documentFolder: URL {
        let fileManager = FileManager.default
        let document = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return document
    }
    
    var importableFiles: [URL] {
        let fileManager = FileManager.default
        let files = try? fileManager.contentsOfDirectory(at: documentFolder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        let importableFiles = files?.filter({ $0.lastPathComponent.contains(".fnotex") }) ?? []
        return importableFiles.sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
    }
    
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 32) {
                    // MARK: Color Scheme
                    VStack(spacing: 5) {
                        SettingCheckmarkRow(label: "System", checked: checkedSystem)
                            .onTapGesture(perform: { self.handleColorSchemeTapped(.system) })
                        
                        SettingCheckmarkRow(label: "Always Light", checked: checkedLight)
                            .onTapGesture(perform: { self.handleColorSchemeTapped(.light) })
                        
                        SettingCheckmarkRow(label: "Always Dark", checked: checkedDark)
                            .onTapGesture(perform: { self.handleColorSchemeTapped(.dark) })
                    }
                    .modifier(SettingSectionModifier(header: "COLOR SCHEME"))
                    
                    // MARK: Markdown
                    VStack(spacing: 5) {
                        Toggle(isOn: useMarkdown) {
                            Text("Use in Note")
                        }
                        .modifier(SettingRowModifier())
                        
                        Toggle(isOn: useMarkdownSoftBreak) {
                            Text("Use Soft Break")
                                .foregroundColor(userPreference.useMarkdown ? .primary : Color(.tertiaryLabel))
                        }
                        .modifier(SettingRowModifier())
                        .disabled(!userPreference.useMarkdown)
                    }
                    .modifier(SettingSectionModifier(header: "MARKDOWN", footer: "Soft break means to create a new line, two return keys are required."))
                    
                    // MARK: Export & Import
                    VStack(spacing: 5) {
                        Button(action: beginExportData) {
                            SettingTextRow(label: "Export Data", detail: "backup data")
                        }
                        
                        Button(action: beginImportData) {
                            SettingTextRow(label: "Import Data", detail: "override data")
                        }
                    }
                    .modifier(SettingSectionModifier(header: "DATA", footer: "Make a backup or import from a file. The files are stored locally on the phone."))
                    
                    // MARK: About
                    VStack(spacing: 5) {
                        SettingTextRow(label: "Version", detail: appVersionNumber)
                    }
                    .modifier(SettingSectionModifier(header: "ABOUT"))
                }
                .padding(.vertical, 32)
                .padding(.horizontal)
            }
            .navigationBarTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet, content: presentationSheet)
    }
}


// MARK: - Sheet & Alert

extension HomeSettingView {
    
    enum Sheet: Identifiable {
        var id: Self { self }
        case importFileList
        case exportFileNaming
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .importFileList:
            let done = { self.sheet = nil }
            let label = { Text("Done").bold() }
            let doneNavItem = Button(action: done, label: label)
            return NavigationView {
                SettingImportFileList(files: importableFiles, onFileSelected: commitImportData)
                    .navigationBarTitle("Select Import File", displayMode: .inline)
                    .navigationBarItems(trailing: doneNavItem)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .eraseToAnyView()
        
        case .exportFileNaming:
            return ModalTextField(viewModel: $textFieldModel)
                .eraseToAnyView()
        }
    }
}


// MARK: Action

extension HomeSettingView {
    
    func handleColorSchemeTapped(_ colorScheme: UserPreference.ColorScheme) {
        userPreference.objectWillChange.send()
        userPreference.colorScheme = colorScheme.rawValue
        userPreference.applyColorScheme()
    }
    
    func beginExportData() {
        textFieldModel.title = "Export File"
        textFieldModel.text = ""
        textFieldModel.placeholder = "Export File Name"
        textFieldModel.prompt = "Make a backup of the current data."
        textFieldModel.isFirstResponder = true
        textFieldModel.onCommit = commitExportData
        sheet = .exportFileNaming
    }
    
    func commitExportData() {
        let fileName = textFieldModel.text.trimmed()
        if !fileName.isEmpty {
            let fileURL = documentFolder.appendingPathComponent("\(fileName).fnotex")
            let exporter = ExportImportDataManager(context: CoreDataStack.current.mainContext)
            exporter.exportData(to: fileURL)
        }
        
        sheet = nil
    }
    
    func beginImportData() {
        sheet = .importFileList
    }
    
    func commitImportData(file: URL) {
        let importer = ExportImportDataManager(context: CoreDataStack.current.mainContext)
        let result = importer.importData(from: file, deleteCurrentData: true)
        result?.quickSave()
        result?.parent?.quickSave()
        sheet = nil
    }
}


struct HomeSettingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeSettingView(userPreference: .shared).colorScheme(.light)
            HomeSettingView(userPreference: .shared).colorScheme(.dark)
        }
    }
}
