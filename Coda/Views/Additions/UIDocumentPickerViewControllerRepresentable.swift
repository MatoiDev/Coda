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

public func moveItemsToTempDirectory(originPath: URL, completion: @escaping (Result<URL, Error>) -> Void) -> Void {
    let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
    let resName = originPath.deletingPathExtension().lastPathComponent
    let targetURL = tempDirectoryURL.appendingPathComponent(resName, conformingTo: .pdf)
    if FileManager.default.fileExists(atPath: targetURL.path) {
        completion(.success(targetURL))
        return
    }
    do {
        try FileManager.default.copyItem(at: originPath, to: targetURL)
        completion(.success(targetURL))
    } catch {
        print(error.localizedDescription)
        completion(.failure(error.localizedDescription))
    }
}

struct UIDocumentPickerViewControllerRepresentable: UIViewControllerRepresentable {
    
    @Binding var documentURLs: [URL]
    
    private func setupViewController() -> UIDocumentPickerViewController {
        let viewController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        viewController.allowsMultipleSelection = false
        return viewController
    }
    
    func makeUIViewController(context: Context) -> some UIDocumentPickerViewController {
        let viewController = self.setupViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(with: self.$documentURLs)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        
        @Binding var documentURLs: [URL]
        
        init(with documentURLs: Binding<[URL]>) {
            self._documentURLs = documentURLs
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url: URL = urls.first, url.startAccessingSecurityScopedResource() {
                if !(self.documentURLs.contains(url)) {
                    self.documentURLs.append(url)
                }
            }
        }
    }
}

