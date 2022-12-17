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
    
    @AppStorage("UserProjects") var userProjects : [String] = []
    @AppStorage("UserPosts") var userPosts : [String] = []
    
    private let db = Firestore.firestore()
    
    // MARK: - Generate ID (Static)
    static func generateProjectID() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<64).map{ _ in letters.randomElement()! })
    }
    
    
    // MARK: - Upload functions
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
    
    func upload(postImage: UIImage, id: String, completion: @escaping (Result<String, Error>) -> Void) -> Void {
        let ref = Storage.storage().reference().child("PostPreviews").child(id)
        
        guard let imageData = postImage.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
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
                completion(.success("\(url)"))
            }
        }
        
    }
    
    func upload(preview: UIImage, id: String, completion: @escaping (Result<String, Error>) -> Void) -> Void {
        let ref = Storage.storage().reference().child("ProjectPreviews").child(id)
        
        guard let imageData = preview.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
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
                completion(.success("\(url)"))
            }
        }
    }
    
    
    // MARK: - Remove functions
    func remove(project id: String) {
        db.collection("Projects").document(id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func remove(projectPriview id: String) {
        let desertRef = Storage.storage().reference().child("ProjectPreviews").child(id)
        // Delete the file
        desertRef.delete { error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // File deleted successfully
            }
        }
    }
    
    
    // MARK: - Create functions
    func createPost(owner userID: String, text: String, image: UIImage?=nil, completion: @escaping (Result<String, Error>) -> Void) {
        
        let id = FSManager.generateProjectID()
        
        // If post has image
        if let image = image {
            self.upload(postImage: image, id: id) { result in
                switch result {
                    
                case .success(let url):
                    self.db.collection("Posts").document(id).setData([
                        
                        "id" : id,
                        "owner": userID,
                        "image": url,
                        "body": text,
                        "time": Date().timeIntervalSince1970,
                        "stars": 0,
                        "date": Date().getFormattedDate(format: "d MMM, HH:mm")
                        
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                            self.showPV = false
                            completion(.failure("Error with creating post: \(err.localizedDescription)"))
                        } else {
                            completion(.success(id))
                        }
                    }
                case .failure(let err):
                    print("FSManager | \(err)")
                    completion(.failure("Error with creating post: \(err.localizedDescription)"))
                    self.showPV = false
                }
            }
        } else {
            self.db.collection("Posts").document(id).setData([
                
                "id" : id,
                "owner": userID,
                "body": text,
                "time": Date().timeIntervalSince1970,
                "stars": 0,
                "date": Date().getFormattedDate(format: "d MMM, HH:mm")
                
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    self.showPV = false
                    completion(.failure("Error with creating post: \(err.localizedDescription)"))
                } else {
                    completion(.success(id))
                }
            }
        }
    }
    
    func createUser(withID id: String, email : String, username: String, name: String, surname: String, mates: Int = 0, reputation : Int = 0, image: UIImage?, language: PLanguages.RawValue) -> Void {
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
                    "projects": [],
                    "posts": [],
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
                        self.userProjects = []
                        self.userPosts = []
                        
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
    
    // MARK: - Check for user existing
    func isUserExist() {
        let docRef = db.collection("Users").document(self.userID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.userExists = true
            } else {
                self.userExists = false
            }
        }
    }
    
    
    
    // MARK: -  Deploy project on FireBase storage
    func deploy(project: UOProject, completion: @escaping (Result<String, Error>) -> Void) {
        self.showPV = true
        print("deploying with ID:")
        print(project.id)
        self.db.collection("Projects").document(project.id).setData([
            
            "id": project.id,
            "name": project.name!,
            "description": project.description!,
            "imageURL": project.imageURL!,
            "link": project.link!
            
        ]) { err in
            if let err = err {
                completion(.failure(err))
                self.showPV = false
            } else {
                completion(.success("Success"))
                self.showPV = false
            }
        }
    }
    
    // MARK: - Add functions
    func add(project id: String, to userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let docRef = db.collection("Users").document(userId)
        
        // Atomically add a new region to the "regions" array field.
        docRef.updateData([
            "projects": FieldValue.arrayUnion([id])
        ]) { err in
            if let err = err {
                completion(.failure("Can not update user's Data: \(err.localizedDescription)"))
            } else {
                completion(.success("Succes"))
            }
        }
    }
    
    func add(post id: String, to userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let docRef = db.collection("Users").document(userId)
        
        // Atomically add a new region to the "regions" array field.
        docRef.updateData([
            "posts": FieldValue.arrayUnion([id])
        ]) { err in
            if let err = err {
                completion(.failure("Can not update user's Data: \(err.localizedDescription)"))
            } else {
                completion(.success("Succes"))
            }
        }
    }
    
    // MARK: - Increment & Decrement functions
    
    func unlike(profilePost postID: String, user userID: String, owner ownerID: String) {
        let postsRef = db.collection("Posts").document(postID)
        let ownerRef = db.collection("Users").document(ownerID)
        
        postsRef.updateData([
            "stars": FieldValue.arrayRemove([userID])
        ]) { err in
            if let err = err {
                print(err)
            } else {
                ownerRef.updateData([
                    "reputation": FieldValue.increment(Int64(-1))
                ])
            }
        }
    }
    
    func like(profilePost postID: String, user userID: String, owner ownerID: String) {
        let postsRef = db.collection("Posts").document(postID)
        
        let ownerRef = db.collection("Users").document(ownerID)
        
        
        
        postsRef.updateData([
            "stars": FieldValue.arrayUnion([userID])
        ]) { err in
            if let err = err {
                print(err)
            } else {
                ownerRef.updateData([
                    "reputation": FieldValue.increment(Int64(1))
                ]) { err in
                    if let err = err {
                        print("Пиздаааааааа \(err)")
                    }
                    
                }
            }
        }
    }
    
    // MARK: - Override/Update/Replace functions
    func updateUser(withID id: String, email : String, username: String, name: String, surname: String, mates: Int = 0, reputation : Int = 0, image: UIImage?, language: PLanguages.RawValue, bio: String, projects: [String]) -> Void {
        self.showPV = true
        
        if let image = image {
            self.upload(image: image) { (result) in
                switch result {
                    
                case .success(let url):
                    self.avatarURL = url.absoluteString
                    self.db.collection("Users").document(id).updateData([
                        
                        "email" : email,
                        "username": username,
                        "name": name,
                        "surname": surname,
                        "mates": mates,
                        "avatarURL": self.avatarURL,
                        "language": language,
                        "projects": projects,
                        "bio": bio
                        
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                            self.showPV = false
                        } else {
                            print("Document successfully updated!")
                            
                            self.userUsername =  username
                            self.userFirstName = name
                            self.userLastName = surname
                            self.userMates = String(mates)
                            self.userLanguage = language
                            self.userBio = bio
                            self.userProjects = projects
                            self.userPosts = []
                            
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
            self.db.collection("Users").document(id).updateData([
                
                "email" : email,
                "username": username,
                "name": name,
                "surname": surname,
                "mates": mates,
                "avatarURL": self.avatarURL,
                "language": language,
                "bio": bio,
                "projects": projects
                
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
                    self.userLanguage = language
                    self.userBio = bio
                    self.userProjects = projects
                    
                    self.userExists = true
                    self.showPV = false
                }
            }
        }
        self.showPV = false
    }
    
    func overrideProject(_ project: UOProject, completion: @escaping (Result<String, Error>) -> Void) {
        self.showPV = true
        self.db.collection("Projects").document(project.id).setData([
            
            "id": project.id,
            "name": project.name!,
            "description": project.description!,
            "imageURL": project.imageURL!,
            "link": project.link!
            
        ]) { err in
            if let err = err {
                completion(.failure(err))
                self.showPV = false
            } else {
                completion(.success("Success"))
                self.showPV = false
            }
        }
    }
    
    func replaceProjects(owner id: String, data: [String]) { }
    
    
    // MARK: - Functions for getting stuff
    
    func getUsersData(withID id: String) -> Void {
        if id != "" {
            let docRef = db.collection("Users").document(id)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    
                    self.userUsername = (document.data()?["username"] as? String) ?? "username"
                    self.userFirstName = (document.data()?["name"] as? String) ?? "name"
                    self.userLastName = (document.data()?["surname"] as? String) ?? "surname"
                    self.userMates = (document.data()?["mates"] as? String) ?? "0"
                    self.userReputation = "\(document.data()?["reputation"] as! Int64)"
                    self.userLanguage = (document.data()?["language"] as? String) ?? PLanguages.swift.rawValue
                    self.userBio = (document.data()?["bio"] as? String) ?? "Bio"
                    self.userProjects = (document.data()?["projects"] as? [String]) ?? []
                    self.userPosts = (document.data()?["posts"] as? [String])?.reversed() ?? []
                    self.avatarURL = (document.data()?["avatarURL"] as? String) ?? "AvatarURL"
                    
                    
                }
            }
        }
    }
    
    func getPost(by id: String, completion: @escaping (Result<Dictionary<String, Any>, Error>) -> Void) async -> Void {
        
        var res : Dictionary<String, Any> = Dictionary<String, Any>()
        if id != "" {
            let docRef = db.collection("Posts").document(id)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    res["body"] = (document.data()?["body"] as? String) ?? "Post body"
                    res["date"] = (document.data()?["date"] as? String) ?? "0"
                    res["time"] = (document.data()?["time"] as? Int) ?? 0
                    if let url = (document.data()?["image"] as? String) { res["image"] =  url }
                    res["stars"] = (document.data()?["stars"] as? [String]) ?? []
                    res["owner"] = (document.data()?["owner"] as? String) ?? "Post owner"
                    completion(.success(res))
                } else {
                    completion(.failure("The post does not exist"))
                }
            }
        } else {
            completion(.failure("Incorrect id"))
        }
        
    }
    
    func getUserName(forID id: String, completion: @escaping (Result<String, Error>) -> Void) async {
        
        let docRef = db.collection("Users").document(id)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                if let username = (document.data()?["username"] as? String) {
                    completion(.success(username))
                } else { completion(.failure("Username")) }
                
            } else { completion(.failure("Username")) }
        }
    }
    
    func getPostImage(from url: String, completion: @escaping (Result<UIImage, Error>) -> Void) async {
        print(url)
        let ref = Storage.storage().reference().child("PostPreviews").child(url)
        ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                completion(.failure("Could not load the image: \(error)"))
            } else {
                let image = UIImage(data: data!)!
                completion(.success(image))
            }
        }
    }
    
    func getProjectImage(from url: String, completion: @escaping (Result<UIImage, Error>) -> Void) async {
        print("Project url: \(url)")
        let ref = Storage.storage().reference().child("ProjectPreviews").child(url)
        ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                completion(.failure("Could not load the image: \(error)"))
            } else {
                let image = UIImage(data: data!)!
                completion(.success(image))
            }
        }
    }
    
    
    func getProject(by id: String, completion: @escaping (Result<Dictionary<String, String>, Error>) -> Void) -> Void {
        var res : Dictionary<String, String> = Dictionary<String, String>()
        if id != "" {
            let docRef = db.collection("Projects").document(id)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    res["name"] = (document.data()?["name"] as? String) ?? "Project name"
                    res["description"] = (document.data()?["description"] as? String) ?? "Project description"
                    res["imageURL"] = (document.data()?["imageURL"] as? String) ?? "Project imageURL"
                    res["link"] = (document.data()?["link"] as? String) ?? "Project link"
                    completion(.success(res))
                } else {
                    completion(.failure("The project does not exist"))
                }
            }
        } else {
            completion(.failure("Incorrect id"))
        }
    }
}

