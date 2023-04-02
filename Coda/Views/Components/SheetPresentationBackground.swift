//
//  SheetPresentationBackground.swift
//  Coda
//
//  Created by Matoi on 03.04.2023.
//
import SwiftUI


struct PresentationBackgroundView: UIViewRepresentable {
    
    var presentationBackgroundColor = Color.clear

    @MainActor
    private static var backgroundColor: UIColor?
    
    func makeUIView(context: Context) -> UIView {
        
        class DummyView: UIView {
            var presentationBackgroundColor = UIColor.clear
            
            override func didMoveToSuperview() {
                super.didMoveToSuperview()
                superview?.superview?.backgroundColor = presentationBackgroundColor
            }
        }
        
        let presentationBackgroundUIColor = UIColor(presentationBackgroundColor)
        let dummyView = DummyView()
        dummyView.presentationBackgroundColor = presentationBackgroundUIColor
        
        Task {
            Self.backgroundColor = dummyView.superview?.superview?.backgroundColor
            dummyView.superview?.superview?.backgroundColor = presentationBackgroundUIColor
        }
        
        return dummyView
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        uiView.superview?.superview?.backgroundColor = Self.backgroundColor
    }
    
    func updateUIView(_ uiView: UIView, context: Context) { /* likely there is need to update */}
}

extension View {
    func presentationBackground(_ color: Color = .clear) -> some View {
        self.background(PresentationBackgroundView(presentationBackgroundColor: color))
    }
}
