//
//  TextEditorWithPlaceHolder.swift
//  Coda
//
//  Created by Matoi on 11.04.2023.
//

import SwiftUI


struct TextEditorWithPlaceholder: View {
    var placeholderText: String
    @Binding var enteredText: String
    
    var body: some View {
#if os(iOS)
        TextEditor(text: $enteredText)
            .background(placeholder())
#elseif os(macOS)
        TextEditor(text: $enteredText)
            .overlay(placeholder())
#endif
    }
    
    @ViewBuilder
    private func placeholder() -> some View {
        
        if enteredText.isEmpty {
            HStack {
                VStack {
                    Text(LocalizedStringKey(placeholderText))
                    
                        .padding(.leading, 4)
                        .padding(.top, 8)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                Spacer()
            }.allowsHitTesting(false)
        }
    }
}


