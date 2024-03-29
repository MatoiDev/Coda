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
    @Published var successfullyLoggedIn: Bool = false // Вошёл ли пользователь в систему
    @Published var errorHandler: String = "" // Лог ошибок
    @Published var showLoading: Bool = false // Для анимации при входе
    
    @AppStorage("UserEmail") private var userEmail : String = ""
    @AppStorage("UserID") private var userID : String = ""
    @AppStorage("IsUserExists") private var userExists : Bool = false
    @AppStorage("ShowPV") private var showPV: Bool = false

    @AppStorage("UserUsername") var userUsername: String = ""
    @AppStorage("UserFirstName") var userFirstName: String = ""
    @AppStorage("UserLastName") var userLastName: String = ""
    @AppStorage("UserMates") var userMates: String = ""
    @AppStorage("avatarURL") var avatarURL: String = ""
    @AppStorage("UserReputation") var userReputation: String = ""
    @AppStorage("UserLanguage") var userLanguage: PLanguages.RawValue = ""
    @AppStorage("UserBio") var userBio : String = ""
    @AppStorage("UserProjects") var userProjects : [String] = []
    @AppStorage("UserPosts") var userPosts : [String] = []
    @AppStorage("UserRegisterDate") var userRegisterDate: String = ""
    
    @AppStorage("LoginUserID") var loginUserID: String = ""
    @AppStorage("LoginUserAvatarID") var loginUserAvatarID: String = ""
    
    
    @ObservedObject var fsmanager : FSManager = FSManager()

    static let shared = AuthenticationState()
    
    
    private enum CodingKeys: String, CodingKey {
        case loggedInUser
        case isAuthenticating
        case error
        case successfullyLoggedIn
        case errorHandler
        case showLoading
      }

    private let auth = Auth.auth() // Экземпляр FirebaseAuth, отвечает за аутентификацию
    var provider = OAuthProvider(providerID: "github.com") // Провайдер, необходим для авторизации через GitHub


    private func resetOwnInfo() -> Void {
        
        self.userEmail  = ""
        self.userID  = ""
        self.userExists = false
        self.showPV = false
        self.userUsername = ""
        self.userFirstName = ""
        self.userLastName = ""
        self.userMates = ""
        self.avatarURL = ""
        self.userReputation = ""
        self.userLanguage = ""
        self.userBio = ""
        self.userProjects = []
        self.userPosts = []
        self.loginUserID = ""
        self.loginUserAvatarID = ""
        self.userRegisterDate = ""
        
    }
    
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    self.showLoading = false
                }
            }
            return
        }
        self.showLoading = true
        auth.createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorHandler = error.localizedDescription
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        self.showLoading = false
                    }
                }
            } else {
                self.successfullyLoggedIn = true
                self.loggedInUser = self.auth.currentUser
                
                self.userEmail = email
                
                if let uid : String = self.loggedInUser?.uid {
                    self.userID = uid // ID текущего пользователя (может использоваться при переходе на страницу другого пользователья)
                    self.loginUserID = uid // ID только зарегистрированного пользователя/пользователя, сделавшего вход
                }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        self.showLoading = false
                    }
                }
            }
        }

    }

    func signInWith(email: String, password: String) -> Void { // Войти с помощью почты
        self.showLoading = true
        auth.signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorHandler = error.localizedDescription
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        self.showLoading = false
                    }
                }
            } else {
                self.successfullyLoggedIn = true
                self.loggedInUser = self.auth.currentUser
                
                self.userEmail = email
                
                if let uid : String = self.loggedInUser?.uid {
                    self.userID = uid // ID текущего пользователя (может использоваться при переходе на страницу другого пользователья)
                    self.loginUserID = uid // ID только зарегистрированного пользователя/пользователя, сделавшего вход
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        self.showLoading = false
                    }
                }
            }
        }
    }


    func signInWithGitHub() -> Void { // Войти с помощью GitHub
        self.provider.scopes = ["user:email", "repo"]
        self.showLoading = true
        provider.getCredentialWith(nil) { credential, error in
            if let error = error {
                self.errorHandler = error.localizedDescription
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        self.showLoading = false
                    }
                }
            }
            if let credential = credential {
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        self.errorHandler = error.localizedDescription
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                self.showLoading = false
                            }
                        }

                    }
                    // User is signed in.
                    // IdP data available in authResult.additionalUserInfo.profile.

                    guard let oauthCredential = authResult?.credential as? OAuthCredential else {
                        return
                    }
                    // GitHub OAuth access token can also be retrieved by:
                    // oauthCredential.accessToken
                    // GitHub OAuth ID token can be retrieved by calling:
                    // oauthCredential.idToken
                    self.successfullyLoggedIn = true
                    self.loggedInUser = self.auth.currentUser
                    
                    if let mail = self.loggedInUser?.email {
                        self.userEmail = mail
                    }
                    
                    if let uid : String = self.loggedInUser?.uid {
                        self.userID = uid // ID текущего пользователя (может использоваться при переходе на страницу другого пользователья)
                        self.loginUserID = uid // ID только зарегистрированного пользователя/пользователя, сделавшего вход
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            self.showLoading = false
                        }
                    }
                }
            }
        }
    }

    func signOut() -> Void {
        self.showPV = true
        do {
            try auth.signOut()
            
            self.loggedInUser = nil
            self.successfullyLoggedIn = false
            
            self.resetOwnInfo()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                
                self.showPV = false
            }
            
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError.localizedDescription)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                self.showPV = false
            }
        }
    }

}
