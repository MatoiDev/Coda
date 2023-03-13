//
//  ProjectPreview.swift
//  Coda
//
//  Created by Matoi on 12.03.2023.
//

import SwiftUI

/*
    Project
 
 - id: String
 - author: userID
 
 - (e) category: ScopeTopic ++
 - (e) subTopic: Subtopic ++
 - (e)* title: String ++
 - (e)* description: String ++
 - (e) images: UIImage -> ProjectImages ++
 - (e) files: Files -> ProjectFiles +
 - (e)* languages: LangDescriptor +
 - (e)* linkToSurce: String +
 - (e) projectDetails: String + // Всякая информаия о проекте, какую бд использовал, какую архитектуру и т д.
 
 - upvotes: [userID] ...
 - downVotes: [userID] ...
 - comments: [commentID] +
 - views: [userID] +
 
 - dateOfPublish: String +
 
 */

struct ProjectPreview: View {
    
    @AppStorage("LoginUserID") var loginUserID: String = ""
    @AppStorage("UserFirstName") var userFirstName: String = ""
    @AppStorage("UserLastName") var userLastName: String = ""
    @AppStorage("UserReputation") var userReputation: String = ""
    
    var title: String
    var description: String
    
    var category: FreelanceTopic
    var devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic
    var adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic
    var designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic
    var testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic
    
    var languages: [LangDescriptor]
    var projectDetails: String
    var previews: [UIImage]?
    var files: [URL]?
    
    var linkToTheSource: String = ""
    
    @StateObject var imageLoader: FirebaseTemporaryImageLoaderVM
    
    @Binding var doneUploading: Bool
    @Binding var rootViewIsActive: Bool
    
    @State private var MBProgressHook: Bool = false
    @State private var MBProgressInPercentages: Double = 0
    
    private let commentsCount = 47
    private let currentDate: String = Date().today(format: "dd MMMM yyyy, HH:mm")
    private let votes: Int = 100
    private let viewsCount = 1641
    
    @Environment(\.dismiss) var dissmiss
    
    @ObservedObject private var fsmanager: FSManager = FSManager()
    @ObservedObject private var observeManager: FirebaseFilesUploadingProgreessManager = FirebaseFilesUploadingProgreessManager()
    
    init(title: String, description: String, category: FreelanceTopic, devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic, adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic, designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic, testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic, languages: [LangDescriptor], projectDetails: String, linkToTheSource: String, previews: [UIImage]? = nil, files: [URL]? = nil, imageLoader: FirebaseTemporaryImageLoaderVM, doneTrigger: Binding<Bool>, rootViewIsActive: Binding<Bool>) {
        
        self._imageLoader = StateObject(wrappedValue: imageLoader)
 
        self.title = title
        self.description = description
        self.category = category
        self.devSubtopic = devSubtopic
        self.adminSubtopic = adminSubtopic
        self.designSubtopic = designSubtopic
        self.testSubtopic = testSubtopic
        self.languages = languages
        self.projectDetails = projectDetails
        self.previews = previews
        self.files = files
        self.linkToTheSource = linkToTheSource
        
        self._doneUploading = doneTrigger
        self._rootViewIsActive = rootViewIsActive
        
        self.userFirstName = userFirstName
        self.userLastName = userLastName
        self.userReputation = userReputation
        
    }

    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    
                    // MARK: - Title
                    
                    HStack {
                        Text(title)
                            .robotoMono(.bold, 25)
                            .lineLimit(2)
                            .minimumScaleFactor(0.2)
                        Spacer()
                    }
                    .padding([.leading, .top], 24)
                    
                    // MARK: - Previews
                    if let previews = self.previews, !previews.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(previews, id: \.self) { preview in
                                    Image(uiImage: preview)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 250, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 25))
                            }
                        }.padding(.horizontal)
                        }.frame(height: 175)
                    }
                    
                    // MARK: - Tags
                    WrappingHStack(tags: self.languages.compactMap {
                        $0 == LangDescriptor.defaultValue ? nil : $0.rawValue
                    } + self.getTags(from: self.projectDetails))
                        .padding(.horizontal)
                    
                    
                    // MARK: - Business card
                    
                    BusinessCard(type: .customer, image: self.$imageLoader.image, error: self.$imageLoader.errorLog, firstName: self.userFirstName, lastName: self.userLastName, reputation: self.userReputation)
                        .padding()
                    // MARK: - Date, responses & views
                    HStack(alignment: .center) {
                        Text(self.currentDate)
                            .padding(.leading, 24)
                            .robotoMono(.light, 12, color: Color(red: 0.80, green: 0.80, blue: 0.80))
                    
                        Spacer()
                        HStack {
                            Text("\(self.commentsCount)")
                                .foregroundColor(.white)
                                .robotoMono(.medium, 14)
                            Image("chat")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .robotoMono(.light, 12, color: Color(red: 0.80, green: 0.80, blue: 0.80))
                            Divider()
                            Text("\(self.votes)")
                                .foregroundColor(.white)
                                .robotoMono(.medium, 14)
                            Image(systemName: "star")
                                .robotoMono(.light, 12, color: Color(red: 0.80, green: 0.80, blue: 0.80))
//                                .padding(.trailing)
                            Divider()
                            Text("\(self.viewsCount)")
                                .foregroundColor(.white)
                                .robotoMono(.medium, 14)
                            Image(systemName: "eye")
                                .robotoMono(.light, 12, color: Color(red: 0.80, green: 0.80, blue: 0.80))
                        }
                   
                        .padding(2)
                        .padding(.horizontal, 4)
                        .background(Color("BubbleMessageRecievedColor"), in: RoundedRectangle(cornerRadius: 30))
                        .overlay {
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color(red: 0.80, green: 0.80, blue: 0.80), lineWidth: 1)
                        }
                        .padding(.trailing)
                        .padding(4)
                        .fixedSize()
                        
         
                    }.padding(.top, -8)
                    
                    // MARK: - Files
                    if let files = self.files, !files.isEmpty {
                        VStack {
                            HStack {
                                Text("Files")
                                    .robotoMono(.semibold, 18, color: .secondary)
                                    Spacer()
                            }.padding(.horizontal, 8)
                                .padding(.bottom, 4)
                                .padding(.horizontal)
                            HStack(alignment: .center, spacing: 8) {
                                Spacer()
                                    ForEach(files, id: \.self) { url in
                                        
                                        if let file_Attr = url.fileAttributes {
                                            VStack(alignment: .center) {
                                                
                                                Image(systemName: "doc.viewfinder")
                                                        .resizable()
                                                        .frame(width: 45, height: 45)
                                                        .symbolRenderingMode(.hierarchical)
                                                        .foregroundColor(.primary)
                                                        .padding(.top)
                                                Spacer()
                                                Text(file_Attr.name)
                                                    .lineLimit(1)
                                                    .padding(.horizontal)
                                                    .robotoMono(.semibold, 13)
                                                
                                                Text(Double(file_Attr.size).bytesToHumanReadFormat())
                                                    .lineLimit(1)
                                                    .padding(.horizontal)
                                                    .robotoMono(.semibold, 10, color: .secondary)
                                                    .padding(.bottom)
                                                
                                            }
                                            .frame(
                                                width: UIScreen.main.bounds.width / 3.5,
                                                height: UIScreen.main.bounds.width / 3.5
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.secondary, lineWidth: 4)
                                            }
                                        }
                                      
                                       
                                }
                                Spacer()
                            }.padding(.horizontal)
                        }
                  
                    }
                    
                
                    // MARK: - Description
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Description")
                                .robotoMono(.semibold, 18, color: .secondary)
                                Spacer()
                        }.padding(.horizontal, 8)
                            .padding(.bottom, 4)
                     
                        Text(LocalizedStringKey(self.description))
                    }
                    .padding(.horizontal)
                    
             
                    
                    // MARK: - Deploy Button
                    HStack {
                        Spacer()
                        Button {
                            self.MBProgressHook.toggle()
                            self.fsmanager.createProject(author: self.loginUserID, title: self.title, description: self.description, category: self.category, devSubtopic: self.devSubtopic, adminSubtopic: self.adminSubtopic, designSubtopic: self.designSubtopic, testSubtopic: self.testSubtopic, languages: self.languages, projectDetails: self.projectDetails, linkToTheSource: self.linkToTheSource, observeManager: self.observeManager) { res in
                                switch res {
                                case .success(let success):
                                    print(success)
                                case .failure(_):
                                    print("fail")
                                }
                            }

                        } label: {
                            // MARK: - Deploy Button Label
                            Text("Confirm & Publish")
                                .robotoMono(.bold, 20, color: .white)
                                .frame(maxWidth: UIScreen.main.bounds.width - 64)
                                .frame(height: 45)
                                .background(LinearGradient(colors: [Color("Register2").opacity(0.5), .cyan.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing))
                              
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(LinearGradient(colors: [Color("Register2"), .cyan], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                        }
                        Spacer()
                    }.padding()
                   
                 
                    Text("")
                        .frame(height: 55)
                }
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("AdditionDarkBackground"))
        }
        .sheet(isPresented: self.$doneUploading, content: {
            ProjectPostPublishingView(onOKButtonPress: {
                self.doneUploading = false
            })
        })
        .onChange(of: self.doneUploading, perform: { newValue in
            if !newValue {
                self.doneUploading = false
                self.rootViewIsActive = false
                
            }
        })
        .hookMBProgressHUD(isPresented: self.$MBProgressHook, progressInPercentages: self.$observeManager.amountPercentage, completion: {
            self.doneUploading = true
            
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("")
            }
        }
    }
    private func getTags(from string: String) -> [String] {
        return string.components(separatedBy: ", ")
    }
}

#if DEBUG

let description: String = """
**Violet** is a tweak to customize your voice assistant and the welcome screen.

Things you can:

- Change the appearance of your Siri
- Choose any of the 19 blurs for your picture that apple provides
- Set the welcome screen (the screen that triggers when you unlock your device)
- Do all of the above with the welcome screen
- Remove Siri's Orb
- And more
 
**Notes**:

- iOS 13 support in next release
- There is a conflict with Alexa's Violet due the same IDs of preference bundles.
"""
struct ProjectPreview_Previews: PreviewProvider {
    static var previews: some View {
        ProjectPreview(title: "Violet - the maid for your iPhone", description: description, category: .Development, devSubtopic: .Offtop, adminSubtopic: .Offtop, designSubtopic: .Offtop, testSubtopic: .Mobile, languages: [.ObjectiveC, .Logos], projectDetails: "Siri, Capitan Hook, Jailbreak, SpringBoard", linkToTheSource: "https://github.com/MatoiDev/Violet", imageLoader: imageLoader, doneTrigger: .constant(false), rootViewIsActive: .constant(true))
    }
}

#endif
