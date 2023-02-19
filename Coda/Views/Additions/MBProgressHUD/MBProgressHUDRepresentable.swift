//
//  MBProgressHUDRepresentable.swift
//  Coda
//
//  Created by Matoi on 18.02.2023.
//

import SwiftUI

struct MBProgressHUDRepresentable: UIViewControllerRepresentable {
    
    @Binding var percent: Double
    @Binding var show: Bool
    
    init(percent: Binding<Double>, show: Binding<Bool>) {
        self._percent = percent
        self._show = show
    }
    
    private var progressHud: Progress = Progress(totalUnitCount: 100)
    
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let hud = MBProgressHUD.showAdded(to: viewController.view, animated: true)
        hud.removeFromSuperViewOnHide = true
        
        self.progressHud.completedUnitCount = 0
        hud.mode = .annularDeterminate
        hud.tintColor = UIColor(named: "Regiter2")
        hud.progressObject = self.progressHud
        
        return viewController
        
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        print("UPDATE! \(self.percent)")
        guard !(self.percent.isNaN || self.percent.isInfinite) else {
            return 
        }
        if let hud = MBProgressHUD.forView(uiViewController.view) {
            hud.progressObject = self.progressHud
            hud.removeFromSuperViewOnHide = true
            DispatchQueue.main.async {
                
                    let roundedPercent = Int64(self.percent)
                    self.progressHud.completedUnitCount = roundedPercent
                    print("AND WE SET \(roundedPercent) to progressHUD")
                    print(self.progressHud.completedUnitCount)
                    if self.progressHud.completedUnitCount == 100 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                            withAnimation {
                                let image: UIImage = UIImage(systemName: "checkmark")!
                            
                                hud.mode = .customView
                                hud.customView = UIImageView(image: image.withTintColor(UIColor(named: "Register2")!))
                            }
                            hud.hide(animated: true, afterDelay: 1)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.show = false
                            }

                            
                        }
                    }
                
            }
        }
    }
}


