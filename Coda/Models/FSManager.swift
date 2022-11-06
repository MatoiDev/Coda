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





class FSManager: ObservableObject {
    @AppStorage("UserID") private var userID : String = ""
    @AppStorage("IsUserExists") var userExists : Bool = false
    
    
    private let db = Firestore.firestore()
    
    
    
    func isUserExist(/*show view: inout Binding<Bool>*/) {
        let docRef = db.collection("Users").document(self.userID)
//        var res: Bool = false
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                self.userExists = true
                
            } else {
                self.userExists = false
            }
        }
        
    }
    
    func createUser(withID id: String, email : String, username: String, name: String, surname: String, mates: Int = 0, reputation : Int = 0, image: Image, language: PLanguages.RawValue) {
        db.collection("Users").document(id).setData([
            
            "email" : email,
            "username": username,
            "name": name,
            "surname": surname,
            "mates": mates,
            "reputation": reputation,
            "language": language
            
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                self.userExists = true
            }
        }
        
    }
    
}
