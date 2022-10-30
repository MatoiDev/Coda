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
                        .foregroundStyle(.ultraThickMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 15).strokeBorder(LinearGradient(colors: [Color("Register2").opacity(0.7), Color("Register1").opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        }
                    Text("Register")
                        .font(.custom("RobotoMono-Medium", size: 20))
                        .foregroundColor(.primary)
                }
                
            }
            .frame(width: 200, height: 50, alignment: .center)
            if authState.errorHandler != "" {
                Text(authState.errorHandler)
                    .frame(height: 10)
                    .foregroundColor(.red)
                    .font(.custom("RobotoMono-Medium", size: 300))  // 1
                    .minimumScaleFactor(0.035)
            }
        }
    }
}

