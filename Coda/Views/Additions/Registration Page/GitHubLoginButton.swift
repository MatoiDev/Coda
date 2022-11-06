//
//  GitHubLoginButton.swift
//  Coda
//
//  Created by Matoi on 26.10.2022.
//

import SwiftUI
import Lottie

struct GitHubLoginButton: View {
    @EnvironmentObject var authState : AuthenticationState
    var body: some View {
        Button {
            authState.signInWithGitHub()
        } label: {
            LottieAnimation(named: "githubLogoWhite")
                .frame(width: 50, height: 50)
        }
    }
}

struct GitHubLoginButton_Previews: PreviewProvider {
    static var previews: some View {
        GitHubLoginButton()
    }
}
