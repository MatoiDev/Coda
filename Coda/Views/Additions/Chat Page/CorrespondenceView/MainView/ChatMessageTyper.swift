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
import TLPhotoPicker

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
    
    @State private var toolBarSendCommentButton: UIBarButtonItem
    @Binding var commentMessageState: MessageState
    
    @Binding var triggerImagePicker: Bool
    @Binding var assets: [TLPHAsset]
    @Binding var commentState: CommentType
    @Binding var nameToReply: String
    
    @State private var replyTo = UIBarButtonItem(title: NSLocalizedString("reply to", comment: "reply to"), style: .plain, target: nil, action: nil)
    @State private var replyName = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    
    private func getAccessoryToolBar() -> UIToolbar {
        
        
        
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 32, height: 32)
        menuBtn.setImage(UIImage(systemName: "photo")!, for: .normal)
        menuBtn.tintColor = .lightGray
        menuBtn.onTap { _ in self.triggerImagePicker = true }
        
        
        let toolbarPickImageButton: UIBarButtonItem = UIBarButtonItem(customView: menuBtn)
        let flexSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        
        replyTo.tintColor = UIColor.white
        replyTo.isEnabled = false
        
        self.replyTo.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "RobotoMono-Medium", size: 14)!], for: .disabled)
        

        replyName.tintColor = UIColor.systemBlue
        replyName.onTap {_ in self.nameToReply = ""; self.commentState = .main}
        
        self.replyName.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "RobotoMono-Bold", size: 16)!], for: .normal)
        self.replyName.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "RobotoMono-Bold", size: 14)!], for: .selected)
        
        


        

        
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
//        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = UIBarStyle.default
        toolbar.isTranslucent = true
        toolbar.tintColor = UIColor.blue
        toolbar.setItems([toolbarPickImageButton, flexSpace, replyTo, replyName, flexSpace, self.toolBarSendCommentButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        return toolbar
    }
    
    
    init(placeholder: String, text: Binding<String>, contentHeight: Binding<CGFloat>, maxContentHeight: CGFloat = 168.0, responder: Binding<Bool>? = nil, messageStateHandler: Binding<MessageState>, imagePickerTrigger: Binding<Bool>?, imageAssets: Binding<[TLPHAsset]>?, commentState: Binding<CommentType>? = nil, nameToReply: Binding<String>? = nil, onSend: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self._text = text
        self._contentHeight = contentHeight
        self.firstResponderIsFantom = responder == nil
        self._firstResponder = responder ?? .constant(false)
        self.maxContentHeight = maxContentHeight
        self._commentMessageState = messageStateHandler
        self._assets = imageAssets ?? .constant([])
        self._commentState = commentState ?? .constant(.main)
        self._nameToReply = nameToReply ?? .constant("")
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
        
        self.toolBarSendCommentButton = UIBarButtonItem(customView: menuBtn)
        self._triggerImagePicker = imagePickerTrigger ?? .constant(false)
        let currWidth = self.toolBarSendCommentButton.customView?.widthAnchor.constraint(equalToConstant: 44)
        currWidth?.isActive = true
        let currHeight = self.toolBarSendCommentButton.customView?.heightAnchor.constraint(equalToConstant: 44)
        currHeight?.isActive = true
        self.toolBarSendCommentButton.customView?.transform = CGAffineTransform(scaleX: 2, y: 2)
        self.toolBarSendCommentButton.isEnabled = self.validate(text: self.text)
        
        
        
    }
    
    
    func makeUIView(context: Context) -> MultilineTextField {
        
        textField.placeholder = self.placeholder
        textField.text = self.text
        
        textField.delegate = context.coordinator
        
        self.textField.backgroundColor = UIColor.black
        
        textField.placeholderColor = self.textField.isFirstResponder ? UIColor.white : UIColor.gray
        textField.isPlaceholderScrollEnabled = true
        textField.leftViewOrigin = CGPoint(x: 8, y: 8)
        textField.spellCheckingType = .no
        
        
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
        
        print(self.commentState.rawValue)
        if self.commentState == .reply {
            
            DispatchQueue.main.async {
                
                
                self.replyName.title = self.nameToReply
                self.replyTo.title = NSLocalizedString("reply to", comment: "reply to")
               

            
                print(self.nameToReply)
            }
        } else {
            DispatchQueue.main.async {
                
                self.replyName.title = ""
                self.replyTo.title = ""
            }
        }
        
        
        
        context.coordinator.toolBarSendCommentButton.isEnabled = self.validate(text: self.text)
        
        if self.commentMessageState == .sending {
            let activityView = UIActivityIndicatorView()
            activityView.startAnimating()
//            let rightConstraint = NSLayoutConstraint(item: activityView, attribute: .right, relatedBy: .equal, toItem: self.toolBarSendCommentButton.customView, attribute: .right, multiplier: 1, constant: -10)
//            self.toolBarSendCommentButton.customView?.addConstraint(rightConstraint)
            context.coordinator.toolBarSendCommentButton.isEnabled = false
            context.coordinator.toolBarSendCommentButton.customView = activityView
            
        } else {
            let config = UIImage.SymbolConfiguration(hierarchicalColor: .white)
            let image: UIImage = UIImage(systemName: "bubble.right.circle.fill", withConfiguration: config)!
            
            let menuBtn = UIButton(type: .custom)
            menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 32, height: 32)
            menuBtn.setImage(image, for: .normal)
            menuBtn.onTap { _ in self.onSend?() }
            context.coordinator.toolBarSendCommentButton.customView = menuBtn
            context.coordinator.toolBarSendCommentButton.customView?.transform = CGAffineTransform(scaleX: 2, y: 2)
            context.coordinator.toolBarSendCommentButton.isEnabled = self.validate(text: self.text)
            
            
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
        return (text.count(of: " ") + text.count(of: "\n") != text.count) || self.assets.count == 1
    }
    
    func makeCoordinator() -> Coordinator {
        
        return Coordinator(with: self.$text, contentHeight: self.$contentHeight, maxContentHeight: self.maxContentHeight, toolBarSendCommentButton: self.$toolBarSendCommentButton)
    }
    
    class Coordinator: NSObject, UITextViewDelegate, KeyboardAccessoryViewDelegate {
        
        let maxContentHeight: CGFloat
        
        @Binding var text: String
        @Binding var contentHeight: CGFloat
        
        @Binding var toolBarSendCommentButton: UIBarButtonItem
        
        init(with text: Binding<String>, contentHeight: Binding<CGFloat>, maxContentHeight: CGFloat, toolBarSendCommentButton: Binding<UIBarButtonItem>) {
            self._text = text
            self._contentHeight = contentHeight
            self.maxContentHeight = maxContentHeight
            self._toolBarSendCommentButton = toolBarSendCommentButton
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

        MultilineTextFieldRepresentable(placeholder: "Write a message...", text: self.$messageText, contentHeight: self.$textFieldHeight, messageStateHandler: .constant(.editing), imagePickerTrigger: .constant(false), imageAssets: nil)
                .robotoMono(.semibold, 15)

                .frame(height: textFieldHeight)
                .multilineTextAlignment(TextAlignment.center)
                .fixedSize(horizontal: false, vertical: true)
                      
    }
}

