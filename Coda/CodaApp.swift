//
//  CodaApp.swift
//  Coda
//
//  Created by Matoi on 25.10.2022.
//

import SwiftUI
import Firebase
import Cachy

@main
struct CodaApp: App {
    
    @AppStorage("hideTabBar") var ASHideTabBar: Bool = false
    
    init() {
        Cachy.isOnlyInMemory = true
        self.ASHideTabBar = false
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
