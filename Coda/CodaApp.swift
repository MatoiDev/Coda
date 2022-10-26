//
//  CodaApp.swift
//  Coda
//
//  Created by Matoi on 25.10.2022.
//

import SwiftUI
import Firebase

@main
struct CodaApp: App {
    init() {
        FirebaseApp.configure()
    }
    @StateObject var authState: AuthenticationState = AuthenticationState.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authState)
        }
    }
}
