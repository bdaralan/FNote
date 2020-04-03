//
//  LanguagePickerWrapper.swift
//  FNote
//
//  Created by Dara Beng on 3/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct LanguagePickerWrapper: UIViewRepresentable {
    
    // MARK: Property
    
    @Binding var primary: Language?
    
    @Binding var secondary: Language?
    
    
    // MARK: Make View
    
    func makeCoordinator() -> Coordinator {
        Coordinator(wrapper: self)
    }
    
    func makeUIView(context: Context) -> UIPickerView {
        context.coordinator.picker
    }
    
    func updateUIView(_ uiView: UIPickerView, context: Context) {
        context.coordinator.update(with: self)
    }
}


// MARK: - Coordinator

extension LanguagePickerWrapper {
    
    class Coordinator: NSObject {
        
        var wrapper: LanguagePickerWrapper
        
        let picker = UIPickerView()
    
        let languages: [Language?]
        
        private(set) var primary = 0
        private(set) var secondary = 0
        
        
        init(wrapper: LanguagePickerWrapper) {
            self.wrapper = wrapper
            languages = [nil] + Language.availableISO639s
            
            super.init()
            picker.dataSource = self
            picker.delegate = self
        }
    }
}


// MARK: - Coordinator Method

extension LanguagePickerWrapper.Coordinator {
    
    func update(with wrapper: LanguagePickerWrapper) {
        self.wrapper = wrapper
        
        if wrapper.primary != languages[primary] {
            if let index = languages.firstIndex(of: wrapper.primary) {
                picker.selectRow(index, inComponent: 0, animated: false)
            }
        }
        
        if wrapper.secondary != languages[secondary] {
            if let index = languages.firstIndex(of: wrapper.secondary) {
                picker.selectRow(index, inComponent: 1, animated: false)
            }
        }
    }
}


extension LanguagePickerWrapper.Coordinator: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        languages[row]?.localized ?? "----"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let language = languages[row]
        
        switch component {
        
        case 0:
            primary = row
            wrapper.primary = language
        
        case 1:
            secondary = row
            wrapper.secondary = language
        
        default: fatalError("🧨 picker did selected unknown component: \(component) 🧨")
        }
    }
}


struct Previews: PreviewProvider {
    @State static private var primary: Language?
    @State static private var secondary: Language?
    static var previews: some View {
        LanguagePickerWrapper(primary: $primary, secondary: $secondary)
    }
}
