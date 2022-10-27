//
//  RegistrationPageMain.swift
//  Coda
//
//  Created by Matoi on 25.10.2022.
//

import SwiftUI

struct RegistrationPageMain: View {
    @EnvironmentObject var authState : AuthenticationState
    @State private var authType : AuthentificationType = .login
    var body: some View {
        ZStack {
            Image("WallpaperRegistration").edgesIgnoringSafeArea(.top)
            VStack {
                InputSheet(authType: .constant(.register))
                    
            }
            
        }
        
    }
}

struct RegistrationPageMain_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationPageMain()
    }
}
