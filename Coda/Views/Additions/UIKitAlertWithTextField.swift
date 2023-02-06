//
//  UIKitAlertWithTextField.swift
//  Coda
//
//  Created by Matoi on 05.02.2023.
//

import SwiftUI
import Combine

class TextFieldAlertViewController: UIViewController {
    
    /// - Parameters:
    ///   - title: to be used as title of the UIAlertController
    ///   - message: to be used as optional message of the UIAlertController
    ///   - text: binding for the text typed into the UITextField
    ///   - isPresented: binding to be set to false when the alert is dismissed (`Done` button tapped)
    ///   - onDone: completion handler on `Done` button tapped
    
    init(title: String, message: String?, text: Binding<String?>, isPresented: Binding<Bool>?, onDone: @escaping (_ url: String) -> ()) {
        self.alertTitle = title
        self.message = message
        self._text = text
        self.isPresented = isPresented
        self.onDone = onDone
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Dependencies
    @Binding private var text: String?
    
    let textAlertHandler: TextAlertHandler = TextAlertHandler()
    
    private let alertTitle: String
    private let message: String?
    private var isPresented: Binding<Bool>?
    private var onDone: (_ url: String) -> ()
    
    // MARK: - Private Properties
    private var subscription: AnyCancellable?
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentAlertController()
    }
    
    private var alert: UIAlertController?
    
    
    private func presentAlertController() {
        guard subscription == nil else { return }
        // MARK: - Alert Controller
        self.alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        
        let titleFont = [NSAttributedString.Key.font: UIFont(name: "RobotoMono-Bold", size: 18.0)!]
        let messageFont = [NSAttributedString.Key.font: UIFont(name: "RobotoMono-Medium", size: 12.0)!]

        let titleAttrString = NSMutableAttributedString(string: alertTitle, attributes: titleFont)
        
        if let message = self.message {
            let messageAttrString = NSMutableAttributedString(string: message, attributes: messageFont)
            self.alert?.setValue(messageAttrString, forKey: "attributedMessage")
        }
        self.alert?.setValue(titleAttrString, forKey: "attributedTitle")
            
        // MARK: - TextField Configuration
        self.alert?.addTextField { [weak self] textField in
            
            textField.placeholder = "URL"
            textField.font = UIFont(name: "RobotoMono-SemiBold", size: 15)
            textField.textColor = .white
            textField.keyboardType = UIKeyboardType.URL
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            textField.addTarget(self, action: #selector(self?.alertTextFieldDidChange(_:)), for: UIControl.Event.editingChanged)
            
            guard let self = self else { return }
            self.subscription = NotificationCenter.default
                .publisher(for: UITextField.textDidChangeNotification, object: textField)
                .map { ($0.object as? UITextField)?.text }
                .assign(to: \.text, on: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.isPresented?.wrappedValue = false
            
        }
        let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
        
            let textField = self.alert?.textFields![0]
            if textField?.text! == "" {
                self.text = "https://google.com"
            } else {
                self.text = textField?.text!
                print("not empty", textField?.text! ?? "")
            }
        
            self.onDone(textField?.text! ?? "")
            self.isPresented?.wrappedValue = false
            
        }
        
        cancelAction.setValue(UIColor(named: "Register2"), forKey: "titleTextColor")

        
        doneAction.setValue(UIColor.cyan, forKey: "titleTextColor")
        
        doneAction.isEnabled = false
        
        self.alert?.addAction(cancelAction)
        self.alert?.addAction(doneAction)
        
        self.alert?.preferredAction = doneAction
        
        present(self.alert!, animated: true, completion: nil)
        
    }
    
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        alert?.actions[1].isEnabled = sender.text!.count > 0
    }
}


struct TextFieldAlert {
    
    // MARK: Properties
    let title: String
    let message: String?
    @Binding var text: String?
    var isPresented: Binding<Bool>? = nil
    var onDone: (_ url: String) -> ()
    
    
    // MARK: Modifiers
    func dismissable(_ isPresented: Binding<Bool>) -> TextFieldAlert {
        TextFieldAlert(title: title, message: message, text: $text, isPresented: isPresented, onDone: self.onDone)
    }
}

extension TextFieldAlert: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = TextFieldAlertViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<TextFieldAlert>) -> UIViewControllerType {
        TextFieldAlertViewController(title: title, message: message, text: $text, isPresented: isPresented, onDone: self.onDone)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType,
                                context: UIViewControllerRepresentableContext<TextFieldAlert>) {
    }
}

struct TextFieldWrapper<PresentingView: View>: View {
    
    @Binding var isPresented: Bool
    let presentingView: PresentingView
    let content: () -> TextFieldAlert
    
    var body: some View {
        ZStack {
            if (isPresented) { content().dismissable($isPresented) }
            presentingView
        }
    }
}


extension View {
    func textFieldAlert(isPresented: Binding<Bool>, content: @escaping () -> TextFieldAlert) -> some View {
        TextFieldWrapper(isPresented: isPresented,
                         presentingView: self,
                         content: content)
    }
}
