//
//  DataEditor.swift
//  Coda
//
//  Created by Matoi on 03.11.2022.
//

import SwiftUI

struct DataEditor: View {
    
    @AppStorage("UserID") private var userID : String = ""
    @AppStorage("UserEmail") private var userEmail : String = ""
    @AppStorage("IsUserExists") var isUserExists : Bool = false
    
    @State var username: String = ""
    @State var name: String = ""
    @State var surname: String = ""
    @State var mates: Int = 8888
    @State var reputation : Int = 14235326
    @State var image: Image = Image("")
    @State var email : String = ""
    @State var id: String  = ""
    @State var language: PLanguages = .swift
    
    private let fsmanager : FSManager = FSManager()
    
    var body: some View {
        VStack {
            
            Text("This is data editor")
            
            TextField("Username", text: self.$username)
                .disableAutocorrection(true)
            TextField("First name", text: self.$name)
                .disableAutocorrection(true)
            TextField("Last name", text: self.$surname)
                .disableAutocorrection(true)
        
            Button("Continue") {
                
                self.id = self.userID
                self.email = self.userEmail
    
                print("_________", self.id, self.email)
                
                fsmanager.createUser(withID: self.id, email: self.email, username: self.username, name: self.name, surname: self.surname, image: self.image, language: self.language.rawValue)
                
                
            }

        }.padding()
        
    }
}

struct DataEditor_Previews: PreviewProvider {
    static var previews: some View {
        DataEditor()
    }
}
