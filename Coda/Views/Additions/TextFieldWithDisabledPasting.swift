//
//  TextFieldWithDisabledPasting.swift
//  Coda
//
//  Created by Matoi on 22.02.2023.
//

import SwiftUI

struct TextFieldWithDisabledPasting: UIViewRepresentable {
    
    @Binding var text: String
    let placeHolder: String
    typealias UIViewType = ProtectedTextField
    
    
    func makeUIView(context: Context) -> ProtectedTextField {
        let textField = ProtectedTextField()
        textField.delegate = context.coordinator
        textField.placeholder = self.placeHolder
        return textField
    }
    
    
    func updateUIView(_ uiView: ProtectedTextField, context: Context) {
        uiView.text = text
    }
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            self._text = text
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }
}

// Custom TextField with disabling paste action
class ProtectedTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        if action == #selector(paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
