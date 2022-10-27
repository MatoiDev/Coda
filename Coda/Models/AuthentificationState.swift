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
    @Published var successfullyLoggedIn : Bool = false // Вошёл ли пользователь в систему
    @Published var errorHandler : String = "" // Лог ошибок
    
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
        guard password == passwordConfirmation else {
            self.errorHandler = "Passwords are not equal!"
            return
        }
        auth.createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorHandler = error.localizedDescription
            } else {
                self.successfullyLoggedIn = true
                self.loggedInUser = self.auth.currentUser
            }
        }
    }
    
    func signInWith(email: String, password: String) -> Void { // Войти с помощью почты
        auth.signIn(withEmail: email, password: password) {authResult, error in
            if let error = error {
                self.errorHandler = error.localizedDescription
            } else {
                self.successfullyLoggedIn = true
                self.loggedInUser = self.auth.currentUser
            }
        }
    }
    
    
    func signInWithGitHub() -> Void { // Войти с помощью GitHub
        self.provider.scopes = ["user:email", "repo"]
        
        provider.getCredentialWith(nil) { credential, error in
            if let error = error {
                self.errorHandler = error.localizedDescription
            }
            if let credential = credential {
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        self.errorHandler = error.localizedDescription

                    }
                    // User is signed in.
                    // IdP data available in authResult.additionalUserInfo.profile.

                    guard let oauthCredential = authResult?.credential as? OAuthCredential else { return }
                    // GitHub OAuth access token can also be retrieved by:
                    // oauthCredential.accessToken
                    // GitHub OAuth ID token can be retrieved by calling:
                    // oauthCredential.idToken
                    self.successfullyLoggedIn = true
                    self.loggedInUser = self.auth.currentUser
                }
            }
        }
        
    }
    
    func signOut() -> Void {
        do {
            try auth.signOut()
            self.loggedInUser = nil
            self.successfullyLoggedIn = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError.localizedDescription)
        }
    }
    
}
