//
//  TLPhotosPickerViewControllerRepresentable.swift
//  Coda
//
//  Created by Matoi on 08.02.2023.
//

import SwiftUI
import TLPhotoPicker

extension TLPHAsset: Identifiable {
    public var id: UUID {
        UUID()
    }
}

struct TLPhotosPickerViewControllerRepresentable: UIViewControllerRepresentable {
    
    @Binding var assets: [TLPHAsset]
    
    private func setupViewController() -> TLPhotosPickerViewController {
        let viewController = TLPhotosPickerViewController()
        viewController.selectedAssets = assets
        self.configureViewController(viewController)
        return viewController
    }
    
    private func configureViewController(_ viewController: TLPhotosPickerViewController) {
        var configure = TLPhotosPickerConfigure()
        configure.selectedColor = UIColor(named: "Register2")!
        configure.allowedVideo = false
        configure.previewAtForceTouch = true
        viewController.configure = configure
    }
    
    func makeUIViewController(context: Context) -> TLPhotosPickerViewController {
        let viewController = self.setupViewController()
        viewController.delegate = context.coordinator
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(with: self.$assets)
    }
    
    
    class Coordinator: NSObject, TLPhotosPickerViewControllerDelegate {
        
        @Binding var assets: [TLPHAsset]
        
        init(with assets: Binding<[TLPHAsset]>) {
            self._assets = assets
        }
        
        func photoPickerDidCancel() {
           print("TLPhotoPicker did cancel")
        }
        func dismissComplete() {
            print("TLPicker dissmisscomplete")
        }
        
        func shouldDismissPhotoPicker(withTLPHAssets assets: [TLPHAsset]) -> Bool {
            var selectedAssets: Array<TLPHAsset> = [TLPHAsset]()
            for i in 0..<3 {
                if let asset = assets[safe: i] {
                    selectedAssets.append(asset)
                }
                
            }
            self.assets = selectedAssets
            return true
        }
    }
}

//struct TLPhotosPickerViewControllerRepresentable_Previews: PreviewProvider {
//    static var previews: some View {
//        TLPhotosPickerViewControllerRepresentable()
//    }
//}
