//
//  UIDocumentPickerViewControllerRepresentable.swift
//  Coda
//
//  Created by Matoi on 16.02.2023.
//

import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers
import PDFKit

struct UIDocumentPickerViewControllerRepresentable: UIViewControllerRepresentable {
    
    private func setupViewController() -> UIDocumentPickerViewController {
        let viewController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        viewController.allowsMultipleSelection = false
        return viewController
    }
    
    func makeUIViewController(context: Context) -> some UIDocumentPickerViewController {
        let viewController = self.setupViewController()
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
