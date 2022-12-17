//
//  UOProject.swift
//  Coda
//
//  Created by Matoi on 26.11.2022.
//

import Foundation
import SwiftUI
import UIKit
import Firebase


class UOProject: ObservableObject {
    
    private(set) var id: String
    
    @Published private(set) var imageURL: String?
    @Published private(set) var name: String?
    @Published private(set) var description: String?
    @Published private(set) var link: String?
    
    private var fsmanager : FSManager = FSManager()
    
    // To create a new project
    init(withId id: String, name: String, description: String, imageURL: String, link: String) {
        
        self.id = id
        self.imageURL = imageURL
        self.name = name
        self.description = description
        self.link = link
    
    }
    // To load an existing prject
    init(withID id: String) {
        self.id = id
        print("I trigger this: \(id)")
        fsmanager.getProject(by: id) { result in
            switch result {
            case .success(let data):
                print("Succes")
                self.name = data["name"]!
                self.description = data["description"]!
                self.imageURL = data["imageURL"]!
                self.link = data["link"]!
                
            case .failure(let failure):
            
                print("Error with getting a Project\(failure)")
                
            }
        }
    }
    
    static func generateProjectID(for name: String) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<64).map{ _ in letters.randomElement()! }) + ":\(name)"
    }
    
}
