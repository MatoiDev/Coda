//
//  UserInfo.swift
//  Coda
//
//  Created by Matoi on 25.10.2022.
//

import Foundation


final class UserInfo : ObservableObject {
    @Published var password: String = ""
    @Published var login: String = ""
}

