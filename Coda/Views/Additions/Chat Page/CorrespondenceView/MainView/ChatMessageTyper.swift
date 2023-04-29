//
//  ChatMessageTyper.swift
//  Coda
//
//  Created by Matoi on 29.12.2022.
//

import SwiftUI
import MultilineTextField
import CoreGraphics
import Combine

enum MessageState {
    
    case editing
    case sending
    case done
}

struct MultilineTextFieldRepresentable: UIViewRepresentable {
    
    let placeholder: String
    let maxContentHeight: CGFloat
    let textField = MultilineTextField()
    
    @Binding var text: String
    @Binding var contentHeight: CGFloat
    @Binding var firstResponder: Bool
    
    private let firstResponderIsFantom: Bool
    private let onSend: (() -> Void)?
    
    private let accessoryManager: KeyboardAccessoryManager
    
    @State private var toolbarButton: UIBarButtonItem
    
    @Binding var commentMessageState: MessageState
    
    
    private func getAccessoryToolBar() -> UIToolbar {
        let flexSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = true
        toolbar.tintColor = UIColor.blue
        toolbar.setItems([flexSpace, self.toolbarButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        return toolbar
    }

    
    init(placeholder: String, text: Binding<String>, contentHeight: Binding<CGFloat>, maxContentHeight: CGFloat = 168.0, responder: Binding<Bool>? = nil, messageStateHandler: Binding<MessageState>, onSend: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self._text = text
        self._contentHeight = contentHeight
        self.firstResponderIsFantom = responder == nil
        self._firstResponder = responder ?? .constant(false)
        self.maxContentHeight = maxContentHeight
        self._commentMessageState = messageStateHandler
        self.onSend = onSend
        
  
        
        let config = UIImage.SymbolConfiguration(hierarchicalColor: .white)
        let image: UIImage = UIImage(systemName: "bubble.right.circle.fill", withConfiguration: config)!

        let keyButtons: [KeyboardAccessoryButton] = [
            KeyboardAccessoryButton(image: image, position: .trailing, tapHandler: self.onSend)
        ]
        self.accessoryManager = KeyboardAccessoryManager(keyButtons: keyButtons, showDismissKeyboardKey: false)
 
        
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 32, height: 32)
        menuBtn.setImage(image, for: .normal)
        menuBtn.onTap { _ in onSend?() }

        self.toolbarButton = UIBarButtonItem(customView: menuBtn)
        let currWidth = self.toolbarButton.customView?.widthAnchor.constraint(equalToConstant: 44)
        currWidth?.isActive = true
        let currHeight = self.toolbarButton.customView?.heightAnchor.constraint(equalToConstant: 44)
        currHeight?.isActive = true
        self.toolbarButton.customView?.transform = CGAffineTransform(scaleX: 2, y: 2)
        self.toolbarButton.isEnabled = self.validate(text: self.text)
        
        
        
    }

    
    func makeUIView(context: Context) -> MultilineTextField {

        textField.placeholder = self.placeholder
        textField.text = self.text
        
        textField.delegate = context.coordinator

        self.textField.backgroundColor = UIColor.black
            
        textField.placeholderColor = self.textField.isFirstResponder ? UIColor.white : UIColor.gray
        textField.isPlaceholderScrollEnabled = true
        textField.leftViewOrigin = CGPoint(x: 8, y: 8)
        textField.keyboardType = .asciiCapable
        
        
        textField.font = UIFont(name: "RobotoMono-SemiBold", size: 15)
        textField.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        textField.layer.cornerRadius = 15.0
        
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
        if let _ = onSend {
            textField.inputAccessoryView = self.getAccessoryToolBar()
        }
        
        return textField
        
    }

    
    func setContentSize(size: CGFloat) {
        self.contentHeight = size > self.maxContentHeight ? self.maxContentHeight : size
    }
    
    func updateUIView(_ uiView: MultilineTextField, context: Context) {
        uiView.text = self.text
        
        DispatchQueue.main.async {
            if self.onSend != nil { // ТехtField не из чата
                uiView.backgroundColor = uiView.isFirstResponder ? UIColor.clear : UIColor.black
            }
        }
   


        context.coordinator.toolbarButton.isEnabled = self.validate(text: self.text)
        
        if self.commentMessageState == .sending {
            context.coordinator.toolbarButton.customView = UIActivityIndicatorView()
        } else {
            let config = UIImage.SymbolConfiguration(hierarchicalColor: .white)
            let image: UIImage = UIImage(systemName: "bubble.right.circle.fill", withConfiguration: config)!

            let menuBtn = UIButton(type: .custom)
            menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 32, height: 32)
            menuBtn.setImage(image, for: .normal)
            menuBtn.onTap { _ in self.onSend?() }
            context.coordinator.toolbarButton.customView = menuBtn
            context.coordinator.toolbarButton.customView?.transform = CGAffineTransform(scaleX: 2, y: 2)
            context.coordinator.toolbarButton.isEnabled = self.validate(text: self.text)
            
            
        }
        
        uiView.selectedRange = NSMakeRange(uiView.text.count, 0)
        if !self.firstResponderIsFantom, self.firstResponder {
            if uiView.canBecomeFirstResponder {
                uiView.becomeFirstResponder()
            }
        }
        DispatchQueue.main.async {

                self.setContentSize(size: uiView.contentSize.height)

            
        }
    }
    
    private func validate(text: String) -> Bool {
        return text.count(of: " ") + text.count(of: "\n") != text.count
    }
    
    func makeCoordinator() -> Coordinator {
        
        return Coordinator(with: self.$text, contentHeight: self.$contentHeight, maxContentHeight: self.maxContentHeight, toolbarButton: self.$toolbarButton)
    }
    
    class Coordinator: NSObject, UITextViewDelegate, KeyboardAccessoryViewDelegate {
        
        let maxContentHeight: CGFloat
        @Binding var text: String
        @Binding var contentHeight: CGFloat
        
        @Binding var toolbarButton: UIBarButtonItem
        
        init(with text: Binding<String>, contentHeight: Binding<CGFloat>, maxContentHeight: CGFloat, toolbarButton: Binding<UIBarButtonItem>) {
            self._text = text
            self._contentHeight = contentHeight
            self.maxContentHeight = maxContentHeight
            self._toolbarButton = toolbarButton
        }
        
        
        func textViewDidChange(_ textView: UITextView) {
            self.text = textView.text
            
            if textView.contentSize.height < self.maxContentHeight {

                    self.contentHeight = textView.contentSize.height
                
            }
            print(self.contentHeight)
        }
        
    }
}

struct ChatMessageTyper: View {
    
    @Binding var messageText: String
    @State var textFieldHeight: CGFloat = 30
    
    var body: some View {

        MultilineTextFieldRepresentable(placeholder: "Write a message...", text: self.$messageText, contentHeight: self.$textFieldHeight, messageStateHandler: .constant(.editing))
                .robotoMono(.semibold, 15)

                .frame(height: textFieldHeight)
                .multilineTextAlignment(TextAlignment.center)
                .fixedSize(horizontal: false, vertical: true)
                      
    }
}

