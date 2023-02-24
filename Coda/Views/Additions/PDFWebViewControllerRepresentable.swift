//
//  PDFWebViewControllerRepresentable.swift
//  Coda
//
//  Created by Matoi on 17.02.2023.
//

import SwiftUI
import UIKit
import PDFKit

class PDFWebViewController: UIViewController {
    
    @Binding var pdfURL: URL?
    private var pdfView: PDFView!
    
    init(url: Binding<URL?>) {
        self._pdfURL = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
                
        self.setPDFView()
        self.fetchPDF()
    }
    
    private func setPDFView() {
        DispatchQueue.main.async {
            self.pdfView = PDFView(frame: self.view.bounds)
            
            self.pdfView.maxScaleFactor = 3;
            self.pdfView.minScaleFactor = self.pdfView.scaleFactorForSizeToFit;
            self.pdfView.autoScales = true;
            self.pdfView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            self.view.addSubview(self.pdfView)
        }
    }
    
    private func fetchPDF() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let pdfURL = self.pdfURL,
                let data = try? Data(contentsOf: pdfURL), let document = PDFDocument(data: data) {
                DispatchQueue.main.async {
                    self.pdfView.document = document
                    self.addShareBarButton()
                }
            }
        }
    }
    
    private func addShareBarButton() {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                            target: self,
                                            action: #selector(self.presentShare))
        barButtonItem.tintColor = .white
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc private func presentShare() {
        guard let pdfDocument = self.pdfView.document?.dataRepresentation() else { return }
        
        let activityViewController = UIActivityViewController(activityItems: [pdfDocument], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        
        self.present(activityViewController, animated: true)
    }
}


struct PDFWebViewControllerRepresentable: UIViewControllerRepresentable {
    
    @Binding var pdfURL: URL?
    
    init(with pdfURL: Binding<URL?>) {
        self._pdfURL = pdfURL
    }
    
    func makeUIViewController(context: Context) -> PDFWebViewController {
        let viewController = PDFWebViewController(url: self.$pdfURL)
        viewController.pdfURL = self.pdfURL
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: PDFWebViewController, context: Context) {}
}
