//
//  HomeSettingView.swift
//  FNote
//
//  Created by Dara Beng on 1/31/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct HomeSettingView: View {
    
    @ObservedObject var preference: UserPreference
    
    @State private var sheet: Sheet?
    
    @State private var textFieldModel = ModalTextFieldModel()
        
    var documentFolder: URL {
        let fileManager = FileManager.default
        let document = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return document
    }
    
    var importableFiles: [URL] {
        let fileManager = FileManager.default
        let files = try? fileManager.contentsOfDirectory(at: documentFolder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        let fileExtension = FNSupportFileType.fnotex.rawValue
        let importableFiles = files?.filter({ $0.pathExtension == fileExtension }) ?? []
        return importableFiles.sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
    }
    
    
    var body: some View {
        NavigationView {
            SettingViewControllerWrapper(preference: preference, onRowSelected: handleRowSelected)
                .navigationBarTitle("Settings", displayMode: .large)
                .edgesIgnoringSafeArea(.all)
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
        case onboardView
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
            
        case .onboardView:
            let done = { self.sheet = nil }
            return OnboardView(viewModel: .init(), alwaysShowXButton: true, onDismiss: done)
                .eraseToAnyView()
        }
    }
    
    func handleRowSelected(_ row: SettingSection.Row) {
        switch row {
        case .welcome:
            sheet = .onboardView
        
        default: break
        }
    }
}


// MARK: Export & Import

extension HomeSettingView {
    
    func beginExportData() {
        textFieldModel.title = "Export File"
        textFieldModel.text = ""
        textFieldModel.placeholder = "Export File Name"
        textFieldModel.prompt = "Make a backup of the current data."
        textFieldModel.isFirstResponder = true
        textFieldModel.onReturnKey = commitExportData
        sheet = .exportFileNaming
    }
    
    func commitExportData() {
        let fileName = textFieldModel.text.trimmed()
        if !fileName.isEmpty {
            let fileExtension = FNSupportFileType.fnotex.rawValue
            let fileURL = documentFolder.appendingPathComponent("\(fileName).\(fileExtension)")
            let exporter = ExportImportDataManager(context: CoreDataStack.current.mainContext)
            if exporter.exportData(to: fileURL) != nil {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
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
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        sheet = nil
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
