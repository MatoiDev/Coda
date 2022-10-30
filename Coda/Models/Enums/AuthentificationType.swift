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
        self == .register ? "Log in" : "Create one"
    }
    
    var footerText: String {
        self == .register ? "Already have an accound?" : "Don't have an account?"
    }
}
