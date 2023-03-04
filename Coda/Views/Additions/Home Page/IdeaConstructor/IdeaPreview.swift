//
//  IdeaPreview.swift
//  Coda
//
//  Created by Matoi on 01.03.2023.
//

import SwiftUI
import Foundation
import Combine

// TODO: Поместить файлы между привью и текстом, сдеать заголовок как у текста.


struct IdeaPreview: View {
    
    @AppStorage("LoginUserID") var loginUserID: String = ""
    @AppStorage("UserFirstName") var userFirstName: String = ""
    @AppStorage("UserLastName") var userLastName: String = ""
    @AppStorage("UserReputation") var userReputation: String = ""
    
    var title: String
    var text: String
    var category: FreelanceTopic
    var difficultyLevel: IdeaDifficultyLevel
    var languages: [LangDescriptor]
    var coreSkills: String
    var previews: [UIImage]?
    var files: [URL]?
    
    @StateObject var imageLoader: FirebaseTemporaryImageLoaderVM
    
    @Binding var doneUploading: Bool
    @Binding var rootViewIsActive: Bool
    
    @State private var MBProgressHook: Bool = false
    @State private var MBProgressInPercentages: Double = 0
    
    private let currentDate: String = Date().today(format: "dd MMMM yyyy, HH:mm")
    
    private let commentsCount = 100
    private let viewsCount = 1
    
    @Environment(\.dismiss) var dissmiss
    
    @ObservedObject private var fsmanager: FSManager = FSManager()
    @ObservedObject private var observeManager: FirebaseFilesUploadingProgreessManager = FirebaseFilesUploadingProgreessManager()
    
    
    init(title: String,
         text: String,
         category: FreelanceTopic,
         difficultyLevel: IdeaDifficultyLevel,
         languages: [LangDescriptor],
         coreSkills: String,
         previews: [UIImage]? = nil, files: [URL]? = nil,
         imageLoader: FirebaseTemporaryImageLoaderVM, doneTrigger: Binding<Bool>, rootViewIsActive: Binding<Bool>
         ) {
        self._imageLoader = StateObject(wrappedValue: imageLoader)
        
        
        self.title = title
        self.text = text
        self.category = category
        self.difficultyLevel = difficultyLevel
        self.languages = languages
        self.coreSkills = coreSkills
        self.previews = previews
        self.files = files
        
        
        
        
        self._doneUploading = doneTrigger
        self._rootViewIsActive = rootViewIsActive
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
                    
                    
                    // MARK: - Tags
                    WrappingHStack(tags: self.languages.compactMap {
                        $0 == LangDescriptor.defaultValue ? nil : $0.rawValue
                    } + self.getTags(from: self.coreSkills))
                        .padding(.horizontal)
                    
                    
                    // MARK: - Business card
                    
                    BusinessCard(type: .author, image: self.$imageLoader.image, error: self.$imageLoader.errorLog, firstName: self.userFirstName, lastName: self.userLastName, reputation: self.userReputation)
                        .padding()
                    
                    // MARK: - Date, comments & views
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
                    
                
                    // MARK: - Text
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Idea Description")
                                .robotoMono(.semibold, 18, color: .secondary)
                                Spacer()
                        }.padding(.horizontal, 8)
                            .padding(.bottom, 4)
                     
                        Text(LocalizedStringKey(self.text))
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    // MARK: - Deploy Button
                    HStack {
                        Spacer()
                        Button {
                            self.MBProgressHook.toggle()
                            self.fsmanager.createIdea(owner: self.loginUserID, title: self.title, text: self.text, category: self.category, difficultyLevel: self.difficultyLevel, languages: self.languages, coreSkills: self.coreSkills, previews: self.previews, files: self.files, observeManager: self.observeManager) { res in
                                switch res {
                                case .success(let ideaID):
                                    print(ideaID)
                                case .failure(let err):
                                    print("Error with uploading and Idea: \(err)")
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
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding()
                   
                 
                    Text("")
                        .frame(height: 55)
                }
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("AdditionDarkBackground"))
        }
        .sheet(isPresented: self.$doneUploading, content: {
            IdeaPostPublishingView(onOKButtonPress: {
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



struct IdeaPreview_Previews: PreviewProvider {
    static var previews: some View {
        IdeaPreview(title: "Написать замену Siri в виде горничной", text: "Кого только не бесит эта сфера, появившаяся ещё в 9 iOS? Хотелось бы иметь возможность убирать её, а так же ставить свои картинки из галереи. Если ещё реализуете возможность добавлять анимированные фотографии или видео - цены вам не будет!", category: .Development, difficultyLevel: .senior, languages: [.Logos], coreSkills: "iOS, jailbreak, Siri, AppCode, ARM-asm, gif", imageLoader: imageLoader, doneTrigger: .constant(false), rootViewIsActive: .constant(true))
    }
}
