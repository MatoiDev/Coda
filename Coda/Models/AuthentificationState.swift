//
//  AuthentificationState.swift
//  Coda
//
//  Created by Matoi on 25.10.2022.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth
import Firebase


class AuthenticationState: NSObject, ObservableObject {
    
    @Published var loggedInUser: User? // Тут храниться текущий зарегистрированный пользователь (аккаунт)
    @Published var isAuthenticating = false // Определяет, авторизируется ли в настоящее время человек
    @Published var error: NSError? // Обработчик ошибок
    
    static let shared = AuthenticationState()
    
    private let auth = Auth.auth() // Экземпляр FirebaseAuth, отвечает за аутентификацию
    var provider = OAuthProvider(providerID: "github.com") // Провайдер, необходим для авторизации через GitHub
    
    
    
    func login(with loginOption: LoginOption) {
        self.isAuthenticating = true
        self.error = nil
        
        switch loginOption {
        case .withGitHub:
            signInWithGitHub()
            
        case let .withEmail(email, password):
            signInWith(email: email, password: password)
        }
    }
    
    func signUpWith(email: String, password: String, passwordConfirmation: String) -> Void { // Зарегистрироваться
        // TODO
    }
    
    func signInWith(email: String, password: String) -> Void { // Войти с помощью почты
        // TODO
    }
    
    func signInWithGitHub() -> Void { // Войти с помощью GitHub
        self.provider.scopes = ["user:email", "repo"]
        
        provider.getCredentialWith(nil) { credential, error in
            if error != nil {
                // Handle error.
            }
            if credential != nil {
                Auth.auth().signIn(with: credential!) { authResult, error in
                    if error != nil {
                        // Handle error.
                    }
                    // User is signed in.
                    // IdP data available in authResult.additionalUserInfo.profile.
                    
                    guard let oauthCredential = authResult?.credential as? OAuthCredential else { return }
                    // GitHub OAuth access token can also be retrieved by:
                    // oauthCredential.accessToken
                    // GitHub OAuth ID token can be retrieved by calling:
                    // oauthCredential.idToken
                }
            }
        }
        
    }
    
    private func handleSignOut() -> Void {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError.localizedDescription)
        }
    }
}
