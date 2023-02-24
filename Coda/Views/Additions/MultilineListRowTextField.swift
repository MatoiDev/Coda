//
//  MultilineListRowTextField.swift
//  Coda
//
//  Created by Matoi on 05.02.2023.
//

import SwiftUI
import UIKit
import Combine



class TextAlertHandler: ObservableObject {
    
    static let sharedInstance: TextAlertHandler = TextAlertHandler()
    var url: PassthroughSubject<String, Never> = PassthroughSubject<String, Never>()
    
}


fileprivate struct UITextViewWrapper: UIViewRepresentable {
    
    typealias UIViewType = UITextView

    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    
    @Binding var triggerLinkAlert: Bool
    
    var onDone: (() -> Void)?

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        
        let textField = UITextView()
        textField.delegate = context.coordinator

        textField.isEditable = true
        textField.font = UIFont(name: "RobotoMono-Medium", size: 14)
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.isScrollEnabled = false
        textField.toggleBoldface(nil)
        
        textField.backgroundColor = UIColor.clear
        
        if nil != onDone {
            textField.returnKeyType = .done
        }

        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }
    
    

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        if uiView.text != self.text {
            uiView.text = self.text
            if uiView.window != nil, !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            }
        }
        
        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height // !! must be called asynchronously
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, alert: self.$triggerLinkAlert, height: $calculatedHeight, onDone: onDone)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        
        enum TextType {
            case bold
            case italic
            case underline
            case strikethrough
            case link
        }
        
        @State private var start: String.Index?
        @State private var end: String.Index?
        
        @State private var textView: UITextView?
        
        @Binding var text: String
        
        @Binding var alertTrigger: Bool
        
        var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
        
        
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?
        
        let textAlertHandler : TextAlertHandler = TextAlertHandler.sharedInstance

        init(text: Binding<String>, alert: Binding<Bool>, height: Binding<CGFloat>, onDone: (() -> Void)? = nil) {
            
            self._text = text
            self._alertTrigger = alert
            self.calculatedHeight = height
            self.onDone = onDone
            
        }
        
        func textViewDidChange(_ textView: UITextView) {
            
            if textView.text.isEmpty && self.text.count > 1  { return } //  Чтобы значение не сбрасывалось при обновлении ячейки
            self.text = textView.text
            UITextViewWrapper.recalculateHeight(view: textView, result: calculatedHeight)
        }
        
        private func makeSelectionPart(_ type: TextType, in textView: UITextView) {
            
            if let offsetRange = textView.selectedTextRange {
                
                let location = textView.offset(from: textView.beginningOfDocument, to: offsetRange.start)
                let length = textView.offset(from: offsetRange.start, to: offsetRange.end)
                
                let start = textView.text.index(textView.text.startIndex, offsetBy: location)
                let end = textView.text.index(start, offsetBy: length)
                
                self.start = start
                self.end = end
                
                switch type {
                case .bold:
                    self.text = textView.text.replacingCharacters(in: start..<end, with: "**\(textView.text[start..<end])**")
                case .italic:
                    self.text = textView.text.replacingCharacters(in: start..<end, with: "*\(textView.text[start..<end])*")
                case .underline:
                    self.text = textView.text.replacingCharacters(in: start..<end, with: "<u>\(textView.text[start..<end])</u>")
                case .strikethrough:
                    self.text = textView.text.replacingCharacters(in: start..<end, with: "~\(textView.text[start..<end])~")
                case .link:
                    self.textAlertHandler.url
                        .sink { stringValue in
                            self.text = textView.text.replacingCharacters(in: start..<end, with: "[\(textView.text[start..<end])](\(stringValue))")
                        }
                        .store(in: &self.cancellable)
                }
            }
        }
        
        
        // Возможность делать текст жирным, курсивом, зачёркнутым и т. д.
        func textView(_ textView: UITextView, editMenuForTextIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
            var additionalActions: [UIMenuElement] = []
            if range.length > 0 {
                let makeBoldAction = UIAction(image: UIImage(systemName: "bold")) { _ in
                    self.makeSelectionPart(.bold, in: textView)
                }
                let makeItalicAction = UIAction(image: UIImage(systemName: "italic"))  { _ in
                    self.makeSelectionPart(.italic, in: textView)
                }
//                let makeUnderlineAction = UIAction(image: UIImage(systemName: "underline")) { _ in
//                    self.makeSelectionPart(.underline, in: textView)
//                }
                let makeStrikethroughAction = UIAction(image: UIImage(systemName: "strikethrough")) { _ in
                    self.makeSelectionPart(.strikethrough, in: textView)
                }
                
                let makeLinkAction = UIAction(image: UIImage(systemName: "link")) { _ in
                    self.alertTrigger = true
                    self.makeSelectionPart(.link, in: textView)
                }
                
                additionalActions = [makeBoldAction, makeItalicAction, /* makeUnderlineAction, */ makeStrikethroughAction, makeLinkAction]
                let submenu = UIMenu(image: UIImage(systemName: "bold.italic.underline"), options: .singleSelection, children: additionalActions)
                return UIMenu(children: [submenu] + suggestedActions)
            }
            return UIMenu(children: additionalActions + suggestedActions)
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if let onDone = self.onDone, text == "\n" {
                textView.resignFirstResponder()
                onDone()
                return false
            }
            return true
        }
    }

}

struct MultilineListRowTextField: View {

    private var placeholder: String
    private var onCommit: (() -> Void)?

    @Binding private var text: String
    
    @Binding private var forLinkAlertTrigger: Bool
    
    private var internalText: Binding<String> {
        Binding<String>(get: { self.text } ) {
            self.text = $0
            self.showingPlaceholder = $0.isEmpty
        }
    }

    @State private var dynamicHeight: CGFloat = 100
    @State private var showingPlaceholder = false
    

    init (_ placeholder: String = "", text: Binding<String>, alertTrigger: Binding<Bool>, onCommit: (() -> Void)? = nil) {
        
        self.placeholder = placeholder
        self.onCommit = onCommit
        self._forLinkAlertTrigger = alertTrigger
        self._text = text
        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
        
    }

    var body: some View {
        UITextViewWrapper(text: self.internalText, calculatedHeight: $dynamicHeight, triggerLinkAlert: self.$forLinkAlertTrigger, onDone: onCommit)
            .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
            .background(placeholderView, alignment: .topLeading)
    }

    var placeholderView: some View {
        Group {
            if showingPlaceholder {
                Text(LocalizedStringKey(placeholder)).foregroundColor(Color(red: 0.36, green: 0.36, blue: 0.36))
                    .padding(.leading, 4)
                    .padding(.top, 8)
            }
        }
    }
}
