//
//  LottieAnimationView.swift
//  Coda
//
//  Created by Matoi on 26.10.2022.
//

import SwiftUI
import UIKit
import Lottie

struct LottieAnimation: UIViewRepresentable {
    
    let name: String
    let isLoopActivated: Bool
    let animationView: LottieAnimationView = LottieAnimationView()
    
    init(named: String, loop: Bool = false) {
        name = named
        isLoopActivated = loop
    }
    
    func makeUIView(context: Context) -> some UIView {
        
        let view = UIView(frame: .zero)
        
        animationView.animation = Animation.named(name)
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        
        if isLoopActivated { animationView.loopMode = .loop }
        
        view.addSubview(animationView)
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        return view
        
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
}

