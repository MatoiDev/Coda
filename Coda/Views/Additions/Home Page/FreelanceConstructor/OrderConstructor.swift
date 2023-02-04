//
//  OrderConstructor.swift
//  Coda
//
//  Created by Matoi on 01.02.2023.
//

import SwiftUI
import MultilineTextField


/*
 
 Order [Freelance]
 - id: String
 - title: String
 - description: String
 - customerID: userID
 - reward: String || Int
 - topic: FreelanceTopic (enum)
 - dateOfPublish: String
 - responses:  Int
 - views: Int
 - upvotes: Int
 - descriptors: [LangDescriptor]
 - imageExamplesURLs: [String]    —>    In Storage: FreelanceOrdersExamples
 
 */

enum FreelanceOrderTypeReward {
    case negotiated
    case specified(price: Int)
}

enum FreelanceTopic {
    case Development
    case Design
    case Administration
    case Testing
}


struct TextView: UIViewRepresentable {
    
    @Binding var text: String
    
//    typealias UIViewType = UITextView
    
    private func configuredUITextView() -> UITextView {
        let textView: UITextView = UITextView()
        
        textView.font = UIFont(name: "RobotoMono-Medium", size: 13)
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        
        return textView
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = self.configuredUITextView()
        
        textView.delegate = context.coordinator
        
        return textView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.text = self.text
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(with: self.$text)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        enum TextType {
            case bold
            case italic
            case underline
            case strikethrough
        }
        
        @Binding var text: String
        
        @State private var start: String.Index?
        @State private var end: String.Index?
        
        @State private var textView: UITextView?
        
        init(with text: Binding<String>) {
            self._text = text
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
                    
                }
                
            }
            
        }
        
        
        
        func textViewDidChange(_ textView: UITextView) {
            self.text = textView.text
        }
        
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
                additionalActions = [makeBoldAction, makeItalicAction, /* makeUnderlineAction, */ makeStrikethroughAction]
            }
            return UIMenu(children: additionalActions + suggestedActions)
            
        }
        
    }
    
    
    
}




struct OrderConstructor: View {
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var reward: FreelanceOrderTypeReward = .negotiated
    @State private var price: Int?
    @State private var topic: FreelanceTopic = .Development
    @State private var images: [UIImage]?
    
    @State private var descriptionTextFieldContentHeight: CGFloat = 600
    
    var body: some View {
        List {
            Section {
                TextField("Title", text: self.$title)
                    .robotoMono(.semibold, 17)
            } header: {
                Text("Main Info")
                    .robotoMono(.semibold, 13)
            }.textCase(nil)
            
            Section {
                TextView(text: self.$description)
            } footer: {
                Text("\(self.description.count)/5000")
            }
           
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("New Order")
                        .robotoMono(.semibold, 18)
                    Text("[Constructor]")
                        .robotoMono(.medium, 13, color: .secondary)
                }
                
            }
        }
    }
}
