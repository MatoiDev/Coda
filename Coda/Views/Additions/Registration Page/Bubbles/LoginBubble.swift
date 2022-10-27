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
                    print(authState.errorHandler)
                    print("fewvfds")
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(.purple)
                        Text("Login")
                            .font(.largeTitle)
                            .foregroundColor(.primary)
                    }
                    
                }
                .frame(width: 200, height: 50, alignment: .center)
                Text(authState.errorHandler)
                    .foregroundColor(.red)
                    .font(.system(size: 300))  // 1
                    .minimumScaleFactor(0.01)
                    
            
        }
    }
}
