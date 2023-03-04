//
//  ProjectEditor.swift
//  Coda
//
//  Created by Matoi on 26.11.2022.
//

import SwiftUI

enum EditorErrors : String {
    
    case notEnoughCharactersInName = "The name must be at least 3 characters long."
    case overloadCharactersCountInName = "The name must be less than 16 characters long."
    
    case notEnoughCharactersInDescription = "The description must be at least 8 characters long."
    case overloadCharactersCountInDescription = "The description must be less than 84 characters"
    
    case emptyLink = "The link field is empty."
    case incorrectLink = "The link is bad formatted."
    
    case reset = ""
    
    
}

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body : some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.backward")
                Text("Back")

            }
                .robotoMono(.bold, 17, color: Color("Register2"))
        }
    }
}

struct ProjectEditor: View {
    
    var projectID: String?
    var project: UOProject?
    var index: Int?
    
    
    
    @State private var name: String? = nil
    @State private var description: String? = nil
    @State private var link: String? = nil
    @State private var image: UIImage? = nil
    @State private var imageURL: String? = nil
    
    @State private var pickImage: Bool = false
    @State var imageCropperPresent: Bool = false
    
    @State private var editMode: Bool = true
    
    @State private var resultLog: EditorErrors.RawValue = EditorErrors.reset.rawValue
    
    @State private var progressViewTrigger: Bool = false
    @State private var done: Bool = false
    
    @Binding var projects: [String]
    
    @AppStorage("UserProjects") var userProjects : [String] = []
    @AppStorage("UserID") private var userID : String = ""
    
    private var fsmanager : FSManager = FSManager()
    
    // MARK: - Init
    init(with id: String = "", projects: Binding<Array<String>>, index: Int? = nil) {
        self.projectID = id
        self.index = index
        
        if id != "" {
            print(id)
            self.editMode = false
            self.project = UOProject(withID: id)
        } else {
            self.name = ""
            self.description = ""
            self.link = ""
        }
        self._projects = projects
        
    }
    
    
    // MARK: - Load project
    private func loadProject() async {
        
        while true {
            if let name = self.project?.name, let description = self.project?.description, let link = self.project?.link, let imageURL = self.project?.imageURL {
                self.name = name
                self.description = description
                self.link = link
                self.imageURL = imageURL
                await self.fsmanager.getProjectImage(from: self.projectID!, completion: { result in
                    switch result {
                    case .success(let img):
                        self.image = img
                    case .failure(let failure):
                        self.image = UIImage(named: "default1")!
                        print(failure)
                    }
                })
                
                return
            }
        }
    }
    
    // MARK: - Save project
    func saveProject(completion: @escaping (Result<String, Error>) -> Void) -> Void {
        if let name = self.name, let description = self.description, let link = self.link, let image = self.image {
            
            guard name.count > 2 else { self.resultLog = EditorErrors.notEnoughCharactersInName.rawValue; self.progressViewTrigger = false; return }
            guard name.count <= 16 else { self.resultLog = EditorErrors.overloadCharactersCountInName.rawValue; self.progressViewTrigger = false; return }
            
            guard description.count > 7 else { self.resultLog = EditorErrors.notEnoughCharactersInDescription.rawValue; self.progressViewTrigger = false; return }
            guard description.count <= 84 else { self.resultLog = EditorErrors.overloadCharactersCountInDescription.rawValue; self.progressViewTrigger = false; return }
            
            guard link != "" else { self.resultLog = EditorErrors.emptyLink.rawValue; self.progressViewTrigger = false; return }
            guard link.split(separator: ":")[0] == "https" else { self.resultLog = EditorErrors.incorrectLink.rawValue; self.progressViewTrigger = false; return }
            
            self.resultLog = EditorErrors.reset.rawValue
            
            let id = UOProject.generateProjectID(for: name)
            self.fsmanager.upload(preview: image, id: id) { result in
                switch result {
                case .success(let url):
                    let proj = UOProject(withId: id, name: name, description: description, imageURL: url, link: link)
                    self.fsmanager.deploy(project: proj) { result in
                        switch result {
                        case .success(_):
                            self.fsmanager.add(project: proj.id, to: self.userID) { res in
                                switch res {
                                case .success(_):
                                    print("lool")
                                    self.projects.append(proj.id)
                                    completion(.success(""))
                                case .failure(let failure):
                                    print(failure)
                                    completion(.failure(failure))
                                }
                            }
                            
                        case .failure(let err):
                            print("Error deploying a project: \(err.localizedDescription)")
                            completion(.failure(err.localizedDescription))
                        }
                    }
                    
                case .failure(let failure):
                    print(failure.localizedDescription)
                    completion(.failure(failure.localizedDescription))
                }
            }
        } else {
            print("Need an alert: The data haven't set")
            completion(.failure("Need an alert: The data haven't set"))
        }

    }
    
    // MARK: - Update or Override project
    func updateProject(id: String, completion: @escaping (Result<String, Error>) -> Void) -> Void {
        
        
        
        if let name = self.name, let description = self.description, let link = self.link, let image = self.image {
            
            guard name.count > 2 else { self.resultLog = EditorErrors.notEnoughCharactersInName.rawValue; self.progressViewTrigger = false; return }
            guard name.count <= 16 else { self.resultLog = EditorErrors.overloadCharactersCountInName.rawValue; self.progressViewTrigger = false; return }
            
            guard description.count > 7 else { self.resultLog = EditorErrors.notEnoughCharactersInDescription.rawValue; self.progressViewTrigger = false; return }
            guard description.count <= 84 else { self.resultLog = EditorErrors.overloadCharactersCountInDescription.rawValue; self.progressViewTrigger = false; return }
            
            guard link != "" else { self.resultLog = EditorErrors.emptyLink.rawValue; self.progressViewTrigger = false; return }
            guard link.split(separator: ":")[0] == "https" else { self.resultLog = EditorErrors.incorrectLink.rawValue; self.progressViewTrigger = false; return }
            
            self.resultLog = EditorErrors.reset.rawValue
            
            if name != "\(self.project!.id.split(separator: ":")[1])" {
                let newID = "\(self.project!.id.split(separator: ":")[0])" + ":" + name
                
                self.fsmanager.upload(preview: image, id: newID) { result in
                    switch result {
                    case .success(let url):
                        let proj = UOProject(withId: newID, name: name, description: description, imageURL: url, link: link)
                        self.fsmanager.remove(projectPriview: id)
                        self.fsmanager.deploy(project: proj) { result in
                            switch result {
                            case .success(_):
                                
                                if let i = self.projects.firstIndex(of: id) {
                                    self.projects[i] = newID
                                }
                                
                                self.fsmanager.replaceProjects(owner: self.userID, data: self.projects)
                                self.fsmanager.remove(project: id)
                                completion(.success(""))
                                
                            case .failure(let err):
                                print("Error deploying a project: \(err.localizedDescription)")
                                completion(.failure(err.localizedDescription))
                            }
                        }
                        
                    case .failure(let failure):
                        print(failure.localizedDescription)
                        completion(.failure(failure.localizedDescription))
                    }
                }
                
            } else {
                
                self.fsmanager.upload(preview: image, id: id) { result in
                    switch result {
                    case .success(let url):
                        let proj = UOProject(withId: id, name: name, description: description, imageURL: url, link: link)
                        self.fsmanager.overrideProject(proj) { result in
                            switch result {
                            case .success(_):
                                print("The project has overriden successfully")
                                completion(.success("The project has overriden successfully"))
                            case .failure(let failure):
                                print("Need an alert: \(failure)")
                                completion(.success("Need an alert: \(failure)"))
                            }
                        }
                        
                    case .failure(let failure):
                        print(failure.localizedDescription)
                        completion(.failure(failure.localizedDescription))
                    }
                }
                
            }
            
        } else {
            print("Need an alert: The data haven't set")
            completion(.failure("Need an alert: The data haven't set"))
        }
    }
    
    var body: some View {
        
        VStack {

            if let _ = self.project {
                // MARK: - Edit Project
                if self.name != nil {
                    List {
                        // MARK: - Image picker
                        Section(header: Text("Preview").robotoMono(.semibold, 13, color: .cyan), footer: (Text("Recommended resolution:").robotoMono(.semibold, 12) as! Text) + (Text(" 1920x1080").robotoMono(.semibold, 12, color: .red) as! Text) + (Text(".").robotoMono(.semibold, 12) as! Text)) {
                            HStack {
                                Spacer()
                                Button {
                                    self.pickImage.toggle()
                                } label: {
                                    
                                    if let image = self.image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width: 267, height: 150, alignment: .center)
                                            .scaledToFit()
                                        
                                    } else {
                                        ProgressView()
                                    }
                                }
                                .frame(width: 267, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 15).strokeBorder(LinearGradient(colors: [Color("Register2").opacity(0.7), .cyan], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                                }
                                .sheet(isPresented: self.$pickImage, onDismiss: {
                                    
                                }) {
                                    ImagePicker(sourceType: .photoLibrary, onImagePicked: { result in
                                        switch result {
                                        case .success(let img):
                                            withAnimation {
                                                self.imageCropperPresent.toggle()
                                            }
                                            
                                            self.image = img
                                        case .failure(let err):
                                            // alert
                                            print(err)
                                        }
                                    })
                                }
                                Spacer()
                            }
                            
                        }
                        .textCase(nil)
                        .listRowBackground(Color.clear)
                        Section(header: Text("Info")
                            .robotoMono(.semibold, 13, color: .cyan),
                                
                                footer: Text(self.resultLog)
                            .robotoMono(.bold, 12, color: .red)
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)) {
                            
                            // MARK: - Name editor
                            TextField(self.name!.isEmpty ? "Name" : self.name!, text: Binding(self.$name)!)
                                .textContentType(.name)
                                .keyboardType(.default)
                                
                            
                            // MARK: - Description editor
                            TextField(self.description!.isEmpty ? "Description" : self.description!, text: Binding(self.$description)!)
                                .textContentType(.name)
                                .keyboardType(.default)
                            
                            // MARK: - Link editor
                            TextField(self.link!.isEmpty ? "Link to a project" : self.link!, text: Binding(self.$link)!)
                                .textContentType(.URL)
                                .keyboardType(.URL)

                        }
                            .textCase(nil)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .lineLimit(1)
                        .minimumScaleFactor(1)
                        .robotoMono(.semibold, 14)
                        
                        Section(footer: Text(self.done ? "Done" : "").foregroundColor(Color.green)) {
                            // MARK: - Save project
                            Button {
                                print("Here")
                                self.progressViewTrigger = true
                                self.updateProject(id: self.projectID!)  { result in
                                    self.progressViewTrigger = false
                                    switch result {
                                    case .success(_):
                                        print("succes with saving proj")
                                        self.done = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3000)) {
                                            self.done = false
                                        }
                                    case .failure(_):
                                        //alert
                                        print("Need an alert")
                                    }
                                    
                                }
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Save Changes")
                                    Spacer()
                                }
                                    .robotoMono(.bold, 17, color: .blue)
                            }
                            
                        }.textCase(nil)
                        
                    }.navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                VStack {
                                    Text("Settings")
                                        .robotoMono(.semibold, 23)
                                        .lineSpacing(0.1)
                                }
                            }
                        } .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                if self.progressViewTrigger {
                                    ProgressView()
                                } else {
                                    Text("")
                                }
                            }
                        }
                }
                
                
            } else {
                
                // MARK: - Create project
                List {
                    // MARK: - Image picker
                    Section(header: Text("Preview").robotoMono(.semibold, 13, color: .cyan), footer: (Text("Recommended resolution:").robotoMono(.semibold, 12) as! Text) + (Text(" 1920x1080").robotoMono(.semibold, 12, color: .red) as! Text) + (Text(".").robotoMono(.semibold, 12) as! Text)) {
                        HStack {
                            Spacer()
                            Button {
                                self.pickImage.toggle()
                            } label: {
                                
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 267, height: 150, alignment: .center)
                                        .scaledToFit()
                                    
                                } else {
                                    Image(uiImage: UIImage(named: "default1")!)
                                        .resizable()
                                        .frame(width: 267, height: 150, alignment: .center)
                                        .scaledToFit()
                                }
                            }
                            .frame(width: 267, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay {
                                RoundedRectangle(cornerRadius: 15).strokeBorder(LinearGradient(colors: [Color("Register2").opacity(0.7), .cyan], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                            }
                            .sheet(isPresented: self.$pickImage, onDismiss: {
                                
                            }) {
                                ImagePicker(sourceType: .photoLibrary, onImagePicked: { result in
                                    switch result {
                                    case .success(let img):
                                        withAnimation {
                                            self.imageCropperPresent.toggle()
                                        }
                                        
                                        self.image = img
                                    case .failure(let err):
                                        // alert
                                        print(err)
                                    }
                                })
                            }
                            Spacer()
                        }
                        
                    }.listRowBackground(Color.clear)
                        .textCase(nil)
                    Section(header: Text("Info").robotoMono(.semibold, 13, color: .cyan), footer: Text(self.resultLog).foregroundColor(.red)) {
                        
                        // MARK: - Name editor
                        TextField(self.name!.isEmpty ? "Name" : self.name!, text: Binding(self.$name)!)
                            .textContentType(.name)
                            .keyboardType(.default)
                            
                        
                        // MARK: - Description editor
                        TextField(self.description!.isEmpty ? "Description" : self.description!, text: Binding(self.$description)!)
                            .textContentType(.name)
                            .keyboardType(.default)
                        
                        // MARK: - Link editor
                        TextField(self.link!.isEmpty ? "Link to a project" : self.link!, text: Binding(self.$link)!)
                            .textContentType(.URL)
                            .keyboardType(.URL)

                    }
                    .textCase(nil)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .lineLimit(1)
                    .minimumScaleFactor(1)
                    .robotoMono(.semibold, 14)
                    
                    Section(footer: Text(self.done ? "Done" : "").foregroundColor(Color.green)) {
                        // MARK: - Save project
                        Button {
                            self.progressViewTrigger = true
                            
                            self.saveProject { result in
                                switch result {
                                case .success(let success):
                                    print(success)
                                    self.progressViewTrigger = false
                                    self.done = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3000)) {
                                        self.done = false
                                    }
                                case .failure(let failure):
                                    print(failure)
                                    self.progressViewTrigger = true
                                }
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Create a project")
                                Spacer()
                            }.foregroundColor(Color.blue)
                                .robotoMono(.bold, 17)
                        
                        }
                        
                    }.textCase(nil)
                    
                }.navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            VStack {
                                Text("Settings")
                                    .robotoMono(.semibold, 23)
                                    .lineSpacing(0.1)
                            }
                        }
                    } .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if self.progressViewTrigger {
                                ProgressView()
                            } else {
                                Text("")
                            }
                        }
                    }
                
                
            }
        }
        
        
        .task {
            if let _ = self.project {
                await self.loadProject()
            }
            
        }
//        .onDisappear {
//            self.fsmanager.getUsersData(withID: self.userID)
//        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        
    }
}


//struct ProjectEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        ProjectEditor(with: "", projects: Binding(["0VvYrU2wv67SDHBqMEjkxuQvot59x5ZNwG77WtXLACzU7s8VJvrQTaSHtBmJdi6w:Matoi"]))
//    }
//}
