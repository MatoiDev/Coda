//
//  RegisterBubble.swift
//  Coda
//
//  Created by Matoi on 26.10.2022.
//

import SwiftUI

struct RegisterBubble: View {
    
    @EnvironmentObject var authState : AuthenticationState
    
    let email : String
    let password : String
    let passwordConfirmation : String
    
    init(withEmail email: String, password: String, confirmation: String) {
        self.email = email
        self.password = password
        self.passwordConfirmation = confirmation
    }
    
    var body: some View {
        VStack {
            Button {
                authState.signUpWith(email: self.email, password: self.password, passwordConfirmation: self.passwordConfirmation)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.purple)
                    Text("Register")
                        .font(.largeTitle)
                        .foregroundColor(.primary)
                }
                
            }
            .frame(width: 200, height: 50, alignment: .center)
            if authState.errorHandler != "" {
                Text(authState.errorHandler)
                    .frame(height: 10)
                    .foregroundColor(.red)
                    .font(.system(size: 300))  // 1
                    .minimumScaleFactor(0.04)
            }
        }
    }
}

