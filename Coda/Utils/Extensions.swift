//
//  Extensions.swift
//  Coda
//
//  Created by Matoi on 26.10.2022.
//

import Foundation
import SwiftUI


extension NSError : Identifiable {
    public var id: Int { code }
}


extension View {
    func backgroundBlur(radius: CGFloat = 3, opaque: Bool = false) -> some View {
        self.background(Blur(radius: radius, opaque: opaque))
    }
}
