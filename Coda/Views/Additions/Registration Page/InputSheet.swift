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
        VStack {
            // MARK: Email Field
            DataBubble(text: self.$email, editHandler: self.$emailCompleted)
            
            // MARK: Password Field
            SecuredDataBubble(withPlaceHolder: "Password", text: self.$password, editHandler: self.$passwordCompleted)
            
            // MARK: Confirm Password
            if self.authType == .register {
                SecuredDataBubble(withPlaceHolder: "Confirm password", text: self.$passwordConfirm, editHandler: self.$passwordConfirmed)
            }
            // MARK: Login Button
            if emailCompleted, passwordCompleted, authType == .register ? passwordConfirmed : true  {
                    LoginBubble()
            }
            Divider()
            GitHubLoginButton()
            // MARK: Github Button
        }
    }
}

struct InputSheet_Previews: PreviewProvider {
    @State var authType : AuthentificationType = .login
    static var previews: some View {
        InputSheet(authType: .constant(.register))
    }
}
