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
                InputSheet(authType: self.$authType)
                
            }
            VStack {
                HStack {
                    Text(authType.footerText)
                        .robotoMono(.medium, 15)
                        
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                    Button {
                        self.authType = self.authType == .login ? .register : .login
                    } label: {
                        Text(self.authType.text)
                            .robotoMono(.medium, 15)                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                    }

                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.vertical, 40)
            
            if self.authState.showLoading {
                ProgressView()
            }
        }
        
    }
    
}

struct RegistrationPageMain_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationPageMain()
    }
}
