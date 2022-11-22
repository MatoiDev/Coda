//
//  FSManager.swift
//  Coda
//
//  Created by Matoi on 03.11.2022.
//

import Foundation
import SwiftUI
import Combine
import FirebaseCore
import FirebaseFirestore
import Firebase
import FirebaseStorage

class FSManager: ObservableObject {
    @AppStorage("UserID") private var userID : String = ""
    @AppStorage("IsUserExists") var userExists : Bool = false
    
    @AppStorage("ShowPV") var showPV: Bool = false
    
    @AppStorage("UserEmail") private var userEmail : String = ""
    @AppStorage("UserUsername") var userUsername: String = ""
    @AppStorage("UserFirstName") var userFirstName: String = ""
    @AppStorage("UserLastName") var userLastName: String = ""
    @AppStorage("UserMates") var userMates: String = ""
    @AppStorage("avatarURL") var avatarURL: String = ""
    @AppStorage("UserReputation") var userReputation: String = ""
    @AppStorage("UserLanguage") var userLanguage: PLanguages.RawValue = ""
    @AppStorage("UserBio") var userBio : String = ""
    
    
    private let db = Firestore.firestore()
    
    func upload(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) -> Void {
        let ref = Storage.storage().reference().child("Avatars").child(self.userID)
        
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        ref.putData(imageData, metadata: metadata) { metadata, error in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            
            ref.downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(url))
            }
        }
    }
    
    //    func loadAvatar(fromURL url: String,  completion: @escaping (Result<UIImage, Error>) -> Void) -> Void {
    //        print(url)
    //        let ref = Storage.storage().reference(forURL: url)
    //        let memory : Int64 = Int64(1048576)
    //        ref.getData(maxSize: memory) { data, err in
    //            guard let image = data else {
    //                completion(.failure(err!))
    //                return
    //            }
    //            completion(.success(UIImage(data: image)!))
    //        }
    //    }
    
    func isUserExist(/*show view: inout Binding<Bool>*/) {
        let docRef = db.collection("Users").document(self.userID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.userExists = true
            } else {
                self.userExists = false
            }
        }
        
    }
    
    func createUser(withID id: String, email : String, username: String, name: String, surname: String, mates: Int = 0, reputation : Int = 0, image: UIImage?, language: PLanguages.RawValue) {
        self.showPV = true
        
        guard let image = image else {
            print("Image didn't load")
            self.showPV = false
            return
        }
        
        self.upload(image: image) { (result) in
            switch result {
                
            case .success(let url):
                self.avatarURL = url.absoluteString
                self.db.collection("Users").document(id).setData([
                    
                    "email" : email,
                    "username": username,
                    "name": name,
                    "surname": surname,
                    "mates": mates,
                    "avatarURL": self.avatarURL,
                    "reputation": reputation,
                    "language": language,
                    "bio": ""
                    
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                        self.showPV = false
                    } else {
                        
                        self.userUsername = username
                        self.userFirstName = name
                        self.userLastName = surname
                        self.userMates = String(mates)
                        self.userReputation = String(reputation)
                        self.userLanguage = language
                        self.userBio = ""
                        
                        print("Document successfully written!")
                        self.userExists = true
                        self.showPV = false
                    }
                }
            case .failure(let err):
                print(err)
                self.showPV = false
            }
        }
    }
    
    
    func updateUser(withID id: String, email : String, username: String, name: String, surname: String, mates: Int = 0, reputation : Int = 0, image: UIImage?, language: PLanguages.RawValue, bio: String) {
        self.showPV = true
        
        if let image = image {
            self.upload(image: image) { (result) in
                switch result {
                    
                case .success(let url):
                    self.avatarURL = url.absoluteString
                    self.db.collection("Users").document(id).setData([
                        
                        "email" : email,
                        "username": username,
                        "name": name,
                        "surname": surname,
                        "mates": mates,
                        "avatarURL": self.avatarURL,
                        "reputation": reputation,
                        "language": language,
                        "bio": bio
                        
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                            self.showPV = false
                        } else {
                            print("Document successfully written!")
                            
                            self.userUsername =  username
                            self.userFirstName = name
                            self.userLastName = surname
                            self.userMates = String(mates)
                            self.userReputation = String(reputation)
                            self.userLanguage = language
                            self.userBio = bio
                            
                            self.userExists = true
                            self.showPV = false
                        }
                    }
                case .failure(let err):
                    print(err)
                    self.showPV = false
                }
            }
            
        } else {
            self.db.collection("Users").document(id).setData([
                
                "email" : email,
                "username": username,
                "name": name,
                "surname": surname,
                "mates": mates,
                "avatarURL": self.avatarURL,
                "reputation": reputation,
                "language": language,
                "bio": bio
                
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    self.showPV = false
                } else {
                    print("Document successfully written!")
                    
                    self.userUsername =  username
                    self.userFirstName = name
                    self.userLastName = surname
                    self.userMates = String(mates)
                    self.userReputation = String(reputation)
                    self.userLanguage = language
                    self.userBio = bio
                    
                    self.userExists = true
                    self.showPV = false
                }
            }
        }
        
        
        self.showPV = false
    }
    
    func getUsersData(withID id: String)/* -> Dictionary<String, Any>?*/ {
        //        var res : Dictionary<String, Any>? = nil
        //        var semaphore : DispatchSemaphore = DispatchSemaphore(value: 1)
        
        /* semaphore.wait(until: DISPATCH_QUEUE_SEMAPHORE(withTimeLapse: CGFloat(0.5))
         __Reply__clock_get_attributes_t {
         __getAttr__ { return nil }
         }
         semaphore.signal()
         */
        
        if id != "" {
            print("But here")
            let docRef = db.collection("Users").document(id)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
            
                    self.userUsername = (document.data()?["username"] as? String) ?? "username"
                    self.userFirstName = (document.data()?["name"] as? String) ?? "name"
                    self.userLastName = (document.data()?["surname"] as? String) ?? "surname"
                    self.userMates = (document.data()?["mates"] as? String) ?? "0"
                    self.userReputation = (document.data()?["reputation"] as? String) ?? "0"
                    self.userLanguage = (document.data()?["language"] as? String) ?? PLanguages.swift.rawValue
                    self.userBio = (document.data()?["bio"] as? String) ?? "Bio"
                    
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    
                }
            }
        }
    }
}

