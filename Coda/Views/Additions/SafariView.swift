//
//  SafariView.swift
//  Coda
//
//  Created by Matoi on 23.01.2023.
//

import SwiftUI
import SafariServices

struct SafariView : UIViewControllerRepresentable {
    
    var url: URL
    @Binding var viewDiactivator: Bool
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let safariView = SFSafariViewController(url: url)
        safariView.preferredControlTintColor = UIColor.black
        safariView.dismissButtonStyle = .close
        safariView.delegate = context.coordinator
        return safariView
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self.$viewDiactivator)
    }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        @Binding var viewDiactivator: Bool
        
        init(_ viewDiactivator: Binding<Bool>) {
            self._viewDiactivator = viewDiactivator
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            print("Close")
            self.viewDiactivator.toggle()
        }
    }
}
