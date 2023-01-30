//
//  ProfileSettingsMain.swift
//  Coda
//
//  Created by Matoi on 19.11.2022.
//

import SwiftUI
import CoreHaptics


struct IFooterTextForMainSettings: View {
    private(set) var text: String
    init(withText text: String) {
        self.text = text
    }
    var body: some View {
        if #available(iOS 16, *) {
            Text(self.text)
                .font(.custom("RobotoMono-SemiBold", size: 11))
                .lineLimit(10)
                .kerning(0.01) // ios 16 and above
                .lineSpacing(0.3)
        } else {
            Text(self.text)
                .font(.custom("RobotoMono-SemiBold", size: 11))
                .lineLimit(10)
                .lineSpacing(0.3)
        }
    }
}

struct ProfileSettingsMain: View {
    @Environment(\.dismiss) var dissmiss
    @EnvironmentObject private var authState : AuthenticationState
    
    private var avatarImage : CachedImageModel!
    
    @State private var imageCropperPresent: Bool = false
    @State private var pickImage: Bool = false
    
    @State private var showPV: Bool = false
    @State private var username: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var avatarurl: String = ""
    @State private var language: PLanguages.RawValue = ""
    @State private var bio: String = ""
    @State private var projects: [String] = []
    @State var avatar : UIImage? = nil
    
    @State private var editMode: EditMode = .inactive
    @State private var engine: CHHapticEngine?
    
    @AppStorage("IsUserExists") private var userExists : Bool = false
    
    @AppStorage("UserEmail") private var userEmail : String = ""
    @AppStorage("UserUsername") var userUsername: String = ""
    @AppStorage("UserFirstName") var userFirstName: String = ""
    @AppStorage("UserLastName") var userLastName: String = ""
    @AppStorage("UserMates") var userMates: String = ""
    @AppStorage("avatarURL") var avatarURL: String = ""
    @AppStorage("UserLanguage") var userLanguage: PLanguages.RawValue = ""
    @AppStorage("UserBio") var userBio : String = ""
    @AppStorage("UserProjects") var userProjects : [String] = []
    
    @AppStorage("UserID") private var userID : String = ""
    
    
    
    private var fsmanager: FSManager = FSManager()
    
    init() {
        self.username = self.userUsername
        self.avatarImage = CachedImageModel(urlString: self.avatarURL)
        UITableView.appearance().sectionFooterHeight = 0
        
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        self.projects.move(fromOffsets: source, toOffset: destination)
    }
    
    private func removeRows(at offsets: IndexSet) {
        self.projects.remove(atOffsets: offsets)
    }
    
    private func setProjects() async {
        
        while true {
            if self.projects == [] {
                self.projects = self.userProjects
                return
            }
        }
        
        
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
                    
                    // MARK: - Profile info
                    Section(header: Text("Profile").foregroundColor(.cyan).font(.custom("RobotoMono-SemiBold", size: 15)),
                            footer: Text("Enter your new username, first name, last name, or edit a profile photo.")
                        .font(.custom("RobotoMono-SemiBold", size: 11))
                        .lineLimit(10)
                        .lineSpacing(0.3)
                        
                    ) {
                        
                        TextField(self.username.isEmpty ? "Username" : self.username, text: self.$username)
                            .textContentType(.nickname)
                            .onAppear {
                                self.username = self.userUsername
                            }
                        TextField(self.firstName.isEmpty ? "First Name" : self.firstName, text: self.$firstName)
                            .onAppear {
                                self.firstName = self.userFirstName
                            }
                        TextField(self.lastName.isEmpty ? "Last Name" : self.lastName, text: self.$lastName)
                            .onAppear {
                                self.lastName = self.userLastName
                            }
                    }
                    .textCase(nil)
                    .textContentType(.name)
                    .keyboardType(.default)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .lineLimit(1)
                    .minimumScaleFactor(1)
                    .font(.custom("RobotoMono-SemiBold", size: 16))
                    
                    
                    // MARK: - Bio
                    Section(footer:
                            Text("Any details such as your age, occupation or city. Example: 23 y.o. Web programmer from St. Petersburg.")
                                .font(.custom("RobotoMono-SemiBold", size: 11))
                                .lineLimit(10)
                                .lineSpacing(0.3)) {
                                    TextField(self.bio.isEmpty ? "Bio" : self.bio, text: self.$bio)
                                .textContentType(.name)
                                .keyboardType(.default)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .font(.custom("RobotoMono-SemiBold", size: 16))
                            .onAppear {
                                self.bio = self.userBio
                            }
                    }
                    
                    // MARK: - Projects
                    
                    Section(header: Text("Pinned Projects").foregroundColor(.cyan).font(.custom("RobotoMono-SemiBold", size: 15))) {
                        
                        if self.projects.count > 0 {
                            ForEach(0..<self.projects.count, id: \.self) { ind in
                                NavigationLink {
                                    
                                    let id = self.projects[ind]
                                    ProjectEditor(with: id, projects: self.$projects, index: ind)
                                    
                                } label: {
                                    let name = "\(self.projects[ind])".split(separator: ":")[1]
                                    Text(name)
                                        
                                }
                                
                                
                            }
                            .onMove(perform: move)
                            .onDelete(perform: self.removeRows)
                            if self.editMode == .inactive {
                                Button {
                                    self.editMode = .active
                                    Vibro.complexSuccess(engine: self.engine)
                                    print("1")
                                } label: {
                                    HStack {
                                            Image(systemName: "square.and.pencil")
                                            Text("Edit")
                                    }
                                    .foregroundColor(Color.blue)
                                    .font(.custom("RobotoMono-SemiBold", size: 15))

                                }
                            }
                        } else {
                            Text("There are now pinned projects!")
                        }
                        
                        
                    }
                     .textCase(nil)
                     .lineLimit(1)
                     .minimumScaleFactor(1)
                     .font(.custom("RobotoMono-SemiBold", size: 16))
                    
                    // MARK: - Pin a project
                    Section {
                        NavigationLink {
                            ProjectEditor(with: "", projects: self.$projects)
                        } label: {
                            Text("Pin a project")
                                .foregroundColor(Color.blue)
                                .font(.custom("RobotoMono-Medium", size: 15))
                            
                            
                        }
                    }.onTapGesture {
                        print("Hitted")
                        
                    }
                    
                    
                    
                    
                    // MARK: - Log Out
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
                .environment(\.editMode, self.$editMode)
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
                    // MARK: - Complete editing projects order button
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.editMode = .inactive
                            Vibro.trigger(.success)
                        } label: {
                            HStack {
                                if self.editMode == .active {
                                    Image(systemName: "square.and.pencil")
                                } else {
                                    Text("")
                                }
                            }
                            .foregroundColor(Color.green)
                            .font(.custom("RobotoMono-Medium", size: 15))
                            
                        }
                    }
                    
                    // MARK: - Save settings button
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
                    // MARK: - Back button
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
            
        }.onAppear {
            Vibro.prepareEngine(engine: &self.engine)
        }
        .task {
            await self.setProjects()
        }

        
    }
    private func saveSettings() {
        
        self.fsmanager.updateUser(withID: self.userID,
                                  email: self.userEmail,
                                  username: self.username.isEmpty ? self.userUsername : self.username,
                                  name: self.firstName.isEmpty ? self.userFirstName : self.firstName,
                                  surname: self.lastName.isEmpty ? self.userLastName : self.lastName,
                                  image: self.avatar, language:
                                    self.language.isEmpty ? self.userLanguage : self.language,
                                  bio: self.bio,
                                  projects: self.projects)
        self.userProjects = self.projects
        
//        self.fsmanager.getUsersData(withID: self.userID)
        self.dissmiss.callAsFunction()
    }
}

struct ProfileSettingsMain_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsMain()
    }
}
