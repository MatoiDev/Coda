//
//  ChatMessageTyper.swift
//  Coda
//
//  Created by Matoi on 29.12.2022.
//

import SwiftUI
import MultilineTextField

struct MultilineTextFieldRepresentable: UIViewRepresentable {
    
    let placeholder: String
    let maxContentHeight: CGFloat
    
    @Binding var text: String
    @Binding var contentHeight: CGFloat
    
    init(placeholder: String, text: Binding<String>, contentHeight: Binding<CGFloat>, maxContentHeight: CGFloat = 168.0) {
        self.placeholder = placeholder
        self._text = text
        self._contentHeight = contentHeight
        self.maxContentHeight = maxContentHeight
    }
    
    func makeUIView(context: Context) -> MultilineTextField {
        let textField = MultilineTextField()
        
        textField.placeholder = self.placeholder
        textField.text = self.text
        
        textField.delegate = context.coordinator
        textField.placeholderColor = UIColor.gray
        textField.isPlaceholderScrollEnabled = true
        textField.leftViewOrigin = CGPoint(x: 8, y: 8)
        
        textField.font = UIFont(name: "RobotoMono-SemiBold", size: 15)
        textField.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        textField.layer.cornerRadius = 15.0
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.white.cgColor
        
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
        return textField
        
    }
    
    func setContentSize(size: CGFloat) {
        self.contentHeight = size > self.maxContentHeight ? self.maxContentHeight : size
    }
    
    func updateUIView(_ uiView: MultilineTextField, context: Context) {
        uiView.text = self.text
        uiView.selectedRange = NSMakeRange(uiView.text.count, 0)
        
        DispatchQueue.main.async {
            withAnimation(.easeOut) {
                self.setContentSize(size: uiView.contentSize.height)
            }
            
        }
    }
    
    func makeCoordinator() -> Coordinator {
        print("coord")
        return Coordinator(with: self.$text, contentHeight: self.$contentHeight, maxContentHeight: self.maxContentHeight)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        let maxContentHeight: CGFloat
        @Binding var text: String
        @Binding var contentHeight: CGFloat
        
        init(with text: Binding<String>, contentHeight: Binding<CGFloat>, maxContentHeight: CGFloat) {
            self._text = text
            self._contentHeight = contentHeight
            self.maxContentHeight = maxContentHeight
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.text = textView.text
            
            if textView.contentSize.height < self.maxContentHeight {
                withAnimation(.easeOut) {
                    self.contentHeight = textView.contentSize.height
                }
                
            }
            print(self.contentHeight)
        }
        
    }
}

struct ChatMessageTyper: View {
    
    @Binding var messageText: String
    @State var textFieldHeight: CGFloat = 30
    
    var body: some View {

            MultilineTextFieldRepresentable(placeholder: "Write a message...", text: self.$messageText, contentHeight: self.$textFieldHeight)
                .font(.custom("RobotoMono-SemiBold", size: 15))
                .frame(maxWidth: .infinity)
                .frame(height: textFieldHeight)
                .multilineTextAlignment(TextAlignment.center)
                .fixedSize(horizontal: false, vertical: true)
                      
    }
}

