//
//  CodaApp.swift
//  Coda
//
//  Created by Matoi on 25.10.2022.
//

import SwiftUI

@main
struct CodaApp: App {
    @StateObject var user: UserInfo = UserInfo()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(user)
        }
    }
}
