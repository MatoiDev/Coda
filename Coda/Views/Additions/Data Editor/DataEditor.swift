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
    
    @State var imageCropperPresent: Bool = false
    
    @State private var pickImage: Bool = false
    @State var avatar : UIImage? = nil
    
    private let fsmanager : FSManager = FSManager()
    
    
    var body: some View {
        
        NavigationView {
            VStack {
                
                Button {
                    self.pickImage.toggle()
                } label: {
                    if let avatar = self.avatar {
                        Image(uiImage: avatar)
                            .resizable()
                            .frame(width: 150, height: 150, alignment: .center)

                    } else {
                        Image("").resizable()
                            .frame(width: 150, height: 150, alignment: .center)
                    }
                    
                    
                }
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(Color.white, lineWidth: 2)
                }
                .sheet(isPresented: self.$pickImage, onDismiss: {
                    
                }) {
                    ImagePicker(sourceType: .photoLibrary, onImagePicked: { result in
                        switch result {
                        case .success(let img):
                            withAnimation {
                                self.imageCropperPresent.toggle()
                            }
                            
                            self.avatar = img
                        case .failure(let err):
                            // alert
                            print(err)
                        }
                    })
                    
                    
                }
                .fullScreenCover(isPresented: self.$imageCropperPresent) {
                    if let avatar = avatar {
                        ImageCropper(shown: self.$imageCropperPresent, image: avatar, croppedImage: self.$avatar)
                    }
                        
                }
            

                
                
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
                    fsmanager.createUser(withID: self.id, email: self.email, username: self.username, name: self.name, surname: self.surname, image: self.avatar, language: self.language.rawValue)
                }

            }.padding()
        
        Spacer()
        }
        
    }


//struct DataEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        DataEditor()
//    }
//}
}
