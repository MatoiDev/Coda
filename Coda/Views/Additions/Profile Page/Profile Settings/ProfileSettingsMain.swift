//
//  ProfileSettingsMain.swift
//  Coda
//
//  Created by Matoi on 19.11.2022.
//

import SwiftUI

struct ProfileSettingsMain: View {
    @Environment(\.dismiss) var dissmiss
    @EnvironmentObject private var authState : AuthenticationState
    
    private var avatarImage : AvatarImageModel!
    
    @State private var imageCropperPresent: Bool = false
    @State private var pickImage: Bool = false
    
    @State private var showPV: Bool = false
    @State private var username: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var avatarurl: String = ""
    @State private var language: PLanguages.RawValue = ""
    @State private var bio: String = ""
    
    @State var avatar : UIImage? = nil
    
    @AppStorage("IsUserExists") private var userExists : Bool = false
    
    
    @AppStorage("UserEmail") private var userEmail : String = ""
    @AppStorage("UserUsername") var userUsername: String = ""
    @AppStorage("UserFirstName") var userFirstName: String = ""
    @AppStorage("UserLastName") var userLastName: String = ""
    @AppStorage("UserMates") var userMates: String = ""
    @AppStorage("avatarURL") var avatarURL: String = ""
    @AppStorage("UserReputation") var userReputation: String = ""
    @AppStorage("UserLanguage") var userLanguage: PLanguages.RawValue = ""
    @AppStorage("UserBio") var userBio : String = ""
    
    @AppStorage("UserID") private var userID : String = ""
    
    
    private var fsmanager: FSManager = FSManager()
    
    init() {
        self.username = self.userUsername
        self.avatarImage = AvatarImageModel(urlString: self.avatarURL)
    
                   UITableView.appearance().sectionFooterHeight = 0

    }
    
    var body: some View {
        NavigationView {
            
            ZStack {
                List {
                    Section {
                        VStack {
                            HStack {
                                Spacer()
                                Button {
                                    self.pickImage.toggle()
                                } label: {
                                    if let avatar = self.avatar {
                                        Image(uiImage: avatar)
                                            .resizable()
                                            .frame(width: 150, height: 150, alignment: .center)
                                        
                                    } else {
                                        Image(uiImage: self.avatarImage.image ?? UIImage(named: "default")!).resizable()
                                            .frame(width: 150, height: 150, alignment: .center)
                                    }
                                }
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .overlay {
                                    Circle().strokeBorder(Color.white)
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
                                Spacer()
                            }
                            Text("Set New Photo")
                                .foregroundColor(.blue)
                                .font(.custom("RobotoMono-SemiBold", size: 15))
                                .onTapGesture {
                                    self.pickImage.toggle()
                                }
                        }.listRowBackground(Color.clear)
                    }
                    Section(header: Text("Profile").foregroundColor(.cyan).font(.custom("RobotoMono-SemiBold", size: 13)), footer: Text("Enter your new username, first name, last name, or edit a profile photo.")) {
                        
                        TextField(self.username == "" ? "Username" : self.username, text: self.$username)
                            .onAppear {
                                self.username = self.userUsername
                            }
                        TextField(self.firstName == "" ? "First Name" : self.firstName, text: self.$firstName)
                            .onAppear {
                                self.firstName = self.userFirstName
                            }
                        TextField(self.lastName == "" ? "Last Name" : self.lastName, text: self.$lastName)
                            .onAppear {
                                self.lastName = self.userLastName
                            }
                    }
                    Section(footer: Text("Any details such as your age, occupation or city. Example: 23 y.o. Web programmer from St. Petersburg.")) {
                        TextField(self.bio == "" ? "Bio" : self.bio, text: self.$bio)
                            .onAppear {
                                self.bio = self.userBio
                            }
                    }
                    Section {
                        Button {
                            self.showPV.toggle()
                            self.authState.signOut()
                        } label: {
                            
                            HStack {
                                Spacer()
                                Text("Log Out")
                                    .foregroundColor(.red)
                                    .font(.custom("RobotoMono-Bold", size: 17))
                                Spacer()
                            }
                            
                            
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Settings").font(.custom("RobotoMono-SemiBold", size: 23)).lineSpacing(0.1)
                                .offset(y:-6)
                        }
                    }
                }
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.saveSettings()
                        } label: {
                            Text("Done")
                                .foregroundColor(.cyan)
                                .font(.custom("RobotoMono-Bold", size: 18))
                                .fontWeight(.black)
                        }
                        
                    }
                }
                
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dissmiss.callAsFunction()
                        } label: {
                            HStack {
                                Image(systemName: "chevron.backward")
                                Text("Back")
                                
                                
                            }.foregroundColor(Color("Register2"))
                                .font(.custom("RobotoMono-Bold", size: 17))
                            
                        }
                    }
                    
                    
                }
                if self.showPV {
                    ProgressView()
                }
            }
            
        }
    }
    private func saveSettings() {
        self.fsmanager.updateUser(withID: self.userID, email: self.userEmail,
                                  username: self.username == "" ? self.userUsername : self.username,
                                  name: self.firstName == "" ? self.userFirstName : self.firstName,
                                  surname: self.lastName == "" ? self.userLastName : self.lastName,
                                  image: self.avatar, language:
                                    self.language == "" ? self.userLanguage : self.language,
                                  bio: self.bio)
        self.dissmiss.callAsFunction()
    }
}

struct ProfileSettingsMain_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsMain()
    }
}
