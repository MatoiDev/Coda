//
//  AuthentificationType.swift
//  Coda
//
//  Created by Matoi on 26.10.2022.
//

import Foundation


enum AuthentificationType : String {
    case login
    case register
    
    var text : String {
        self.rawValue.capitalized
    }
    
    var footerText: String {
        self == .login ? "Already have an accound?" : "Don't have an account?"
    }
}
