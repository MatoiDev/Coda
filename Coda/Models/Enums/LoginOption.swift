//
//  LoginType.swift
//  Coda
//
//  Created by Matoi on 25.10.2022.
//

import Foundation


enum LoginOption {
    case withGitHub
    case withEmail(email: String, password: String)
}
