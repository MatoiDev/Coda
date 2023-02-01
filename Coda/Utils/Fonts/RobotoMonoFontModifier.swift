//
//  RobotoMonoFontModifier.swift
//  Coda
//
//  Created by Matoi on 01.02.2023.
//

import SwiftUI

enum RobotoMonoFontWeight: String {
    case light = "Light"
    case medium = "Medium"
    case semibold = "SemiBold"
    case bold = "Bold"
}

struct RobotoMonoFontModifier: ViewModifier {
    
    let weight: RobotoMonoFontWeight
    let size: CGFloat
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .font(.custom("RobotoMono-\(self.weight)", size: self.size))
            .foregroundColor(self.color)
    }
}

extension View {
    func robotoMono(_ weight: RobotoMonoFontWeight, _ size: CGFloat, color: Color = .white) -> some View {
        modifier(RobotoMonoFontModifier(weight: weight, size: size, color: color))
    }
}
