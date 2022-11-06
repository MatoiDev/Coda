//
//  Extensions.swift
//  Coda
//
//  Created by Matoi on 26.10.2022.
//

import Foundation
import SwiftUI

// MARK: - NSError
extension NSError : Identifiable {
    public var id: Int { code }
}

// MARK: - Blur View
extension View {
    func backgroundBlur(radius: CGFloat = 3, opaque: Bool = false) -> some View {
        self.background(Blur(radius: radius, opaque: opaque))
    }
}

 // MARK: - UserDefaults saving class types
extension UserDefaults {

    func setClass<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
        }
    }

    func getClass<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = object(forKey: key) as? Data,
            let value = try? JSONDecoder().decode(type, from: data) {
            return value
        }
        return nil
    }
}
