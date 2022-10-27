//
//  Blur.swift
//  Coda
//
//  Created by Matoi on 26.10.2022.
//

import SwiftUI

class UIBackDropView: UIView {
    override class var layerClass: AnyClass {
        NSClassFromString("CABackdropLayer") ?? CALayer.self
    }
}

struct Backdrop : UIViewRepresentable {
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    func makeUIView(context: Context) -> UIBackDropView {
        UIBackDropView()
    }
}

struct Blur: View {
    var radius: CGFloat = 3
    var opaque: Bool = false
    
    var body: some View {
        Backdrop()
            .blur(radius: self.radius, opaque: self.opaque)
    }
}
