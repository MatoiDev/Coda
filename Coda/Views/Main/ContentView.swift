//
//  ContentView.swift
//  Coda
//
//  Created by Matoi on 25.10.2022.
//

import SwiftUI
import Firebase
import Combine

struct ContentView: View {
    @EnvironmentObject var authState : AuthenticationState
    @AppStorage("UserID") var userID : String = ""
    
    var body: some View {
        Group {
            if userID.isEmpty {
                RegistrationPageMain()
            } else {
                AppView()
            }
        }
        .animation(.easeInOut)
        .transition(.move(edge: .bottom))
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
