//
//  LoginBubble.swift
//  Coda
//
//  Created by Matoi on 26.10.2022.
//

import SwiftUI

struct LoginBubble: View {
    
    @EnvironmentObject var authState : AuthenticationState
    
    let email : String
    let password : String
    
    init(withEmail email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    var body: some View {
        Group {
                Button {
                    authState.signInWith(email: self.email, password: self.password)
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.ultraThickMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 15).strokeBorder(LinearGradient(colors: [Color("Register2").opacity(0.7), .cyan], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                            }
                        Text("Log in")
                            .robotoMono(.medium, 20)
                    }
                    
                }
                .frame(width: 200, height: 50, alignment: .center)
                Text(authState.errorHandler)
                    .robotoMono(.medium, 20, color: .red)
                    .lineLimit(2)
                    .minimumScaleFactor(0.1)
                    .padding(.horizontal, 32)
                    .multilineTextAlignment(.center)

        }
    }
}
