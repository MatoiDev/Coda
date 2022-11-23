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
    @AppStorage("ShowPV") var showPV: Bool = false
    
    @State var username: String = ""
    @State var name: String = ""
    @State var surname: String = ""
    @State var mates: Int = 8888
    @State var reputation : Int = 14235326
    @State var image: Image = Image("")
    @State var email : String = ""
    @State var id: String  = ""
    @State var language: PLanguages = .swift
    
    @State private var usernameIsOK: Bool = false
    @State private var firstNameIsOK: Bool = false
    @State private var secondNameIsOK: Bool = false
    
    @State var imageCropperPresent: Bool = false
    
    @State private var pickImage: Bool = false
    @State private var avatar : UIImage? = nil
    
    private let fsmanager : FSManager = FSManager()
    
    
    var body: some View {
        
        // MARK: - View
        ScrollView { }
                .backgroundBlur(radius: 25, opaque: true)
                .clipShape(RoundedRectangle(cornerRadius: 45))
                .frame(width: UIScreen.main.bounds.width - 10, height: 500)
                .overlay {
                    RoundedRectangle(cornerRadius: 45).strokeBorder(LinearGradient(colors: [Color("Register2").opacity(0.7), Color.black.opacity(0.7)], startPoint: .top, endPoint: .bottom), lineWidth: 1)
                            .opacity(0.5)            }
                .overlay {
            
            
            ZStack {
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
                        Circle().strokeBorder(LinearGradient(colors: [Color("Register2").opacity(0.7), .cyan], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
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
                    DataEditorInputBubble(withPlaceholder: "Username", editable: self.$username, handler: self.$usernameIsOK)
                    DataEditorInputBubble(withPlaceholder: "First name", editable: self.$name, handler: self.$firstNameIsOK)
                    DataEditorInputBubble(withPlaceholder: "Last name", editable: self.$surname, handler: self.$secondNameIsOK)
                    ChooseLanguageButton(language: self.$language)
                    if self.usernameIsOK, self.firstNameIsOK, self.secondNameIsOK {
                        ContinueBubble {
                            self.id = self.userID
                            self.email = self.userEmail
                            fsmanager.createUser(withID: self.id, email: self.email, username: self.username, name: self.name, surname: self.surname, image: self.avatar, language: self.language.rawValue)
                        }
                    }
                    
                }.padding()
                Spacer()
            }
        
        
        }
        
    }
}


struct DataEditor_Previews: PreviewProvider {
    static var previews: some View {
        DataEditor()
    }
}
