//
//  ContentView.swift
//  Coda
//
//  Created by Matoi on 25.10.2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authState : AuthenticationState
    var body: some View {
        Group {
            if authState.loggedInUser == nil {
                RegistrationPageMain()
            } else {
                Text("Login succes!")
                Button("Log out") {
                    authState.signOut()
                }
            }
        }.animation(.easeInOut)
            .transition(.move(edge: .bottom))
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
