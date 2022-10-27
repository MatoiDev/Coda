//
//  InputSheet.swift
//  Coda
//
//  Created by Matoi on 25.10.2022.
//

import SwiftUI

struct InputSheet: View {
    
    @EnvironmentObject var authState : AuthenticationState
    
    @State private var email : String = ""
    @State private var password : String = ""
    @State private var passwordConfirm : String = ""
    
    @State private var emailCompleted : Bool = false
    @State private var passwordCompleted : Bool = false
    @State private var passwordConfirmed : Bool = false
    
    @Binding var authType : AuthentificationType
    
    var body: some View {
        ZStack {
            // MARK: - View
            ScrollView { }
            .backgroundBlur(radius: 25, opaque: true)
            .clipShape(RoundedRectangle(cornerRadius: 45))
            .frame(width: UIScreen.main.bounds.width - 10, height: 422)
            .overlay {
                RoundedRectangle(cornerRadius: 45).strokeBorder(Color.black, lineWidth: 1)
                .opacity(0.5)            }
            .overlay {
                VStack {
                    VStack {
                        Text("Coda")
                            .font(.custom("RobotoMono-Bold", size: 72))
                            .foregroundColor(.primary)
                            
                        Text(self.authType == .login ? "Log in" : "Create an account")
                            .font(.custom("RobotoMono-Medium", size: 36))
                            .minimumScaleFactor(0.05)
                            .lineLimit(1)
                            .padding(.horizontal, 32)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                        .frame(height: 25)
                    
                    // MARK: - Email Field
                    DataBubble(text: self.$email, editHandler: self.$emailCompleted)
                    Spacer()
                        .frame(height: 25)
                    // MARK: - Password Field
                    SecuredDataBubble(withPlaceHolder: "Password", text: self.$password, editHandler: self.$passwordCompleted)
                    Spacer()
                        .frame(height: 25)
                    // MARK: Confirm Password
                    if self.authType == .register {
                        SecuredDataBubble(withPlaceHolder: "Confirm password", text: self.$passwordConfirm, editHandler: self.$passwordConfirmed)
                        Spacer()
                            .frame(height: 25)
                    }
                    
                    // MARK: Login Button
                    if emailCompleted, passwordCompleted, authType == .register ? passwordConfirmed : true  {
                        RegisterBubble(withEmail: self.email, password: self.password, confirmation: self.passwordConfirm)
                        Spacer()
                            .frame(height: 25)
                    } else {
                        // MARK: - Buttons devider
                        HStack {
                            RoundedRectangle(cornerRadius: 1)
                                .frame(width: UIScreen.main.bounds.width / 4, height: 2)
                                
                            Text("Or")
                                .frame(width: UIScreen.main.bounds.width / 16, height: 8, alignment: .center)
                                
                            RoundedRectangle(cornerRadius: 1)
                                .frame(width: UIScreen.main.bounds.width / 4, height: 2)
                                
                        }.frame(width: UIScreen.main.bounds.width - 50, alignment: .center)
                            .foregroundColor(.secondary)
                            .opacity(0.5)
                        Spacer()
                            .frame(height: 15)
                        // MARK: - Github Button
                        GitHubLoginButton()
                    }
                }
            }.padding(.vertical, 16)
            
        }.frame(maxHeight: .infinity)
            .ignoresSafeArea()
            .padding(.vertical, 16)
        
        
    }
}

struct InputSheet_Previews: PreviewProvider {
    @State var authType : AuthentificationType = .login
    static var previews: some View {
        InputSheet(authType: .constant(.register))
    }
}
