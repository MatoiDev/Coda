//
//  FindTeamPreview.swift
//  Coda
//
//  Created by Matoi on 09.03.2023.
//

import SwiftUI

struct FindTeamPreview: View {
    
    @AppStorage("LoginUserID") var loginUserID: String = ""
    @AppStorage("UserFirstName") var userFirstName: String = ""
    @AppStorage("UserLastName") var userLastName: String = ""
    @AppStorage("UserReputation") var userReputation: String = ""
    
    var title: String
    var text: String
    var category: FreelanceTopic
    
    var devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic
    var adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic
    var designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic
    var testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic
    
    var recruitsCount: Int
    var languages: [LangDescriptor]
    var coreSkills: String
    var previews: [UIImage]?
    
    @StateObject var imageLoader: FirebaseTemporaryImageLoaderVM
    
    @Binding var doneUploading: Bool
    @Binding var rootViewIsActive: Bool
    
    @State private var MBProgressHook: Bool = false
    @State private var MBProgressInPercentages: Double = 0
    
    private let currentDate: String = Date().today(format: "dd MMMM yyyy, HH:mm")
    
    private let commentsCount = 100
    private let viewsCount = 1
    private let recruited = 0 // Сколько пользователей уже набрали
    
    @Environment(\.dismiss) var dissmiss
    
    @ObservedObject private var fsmanager: FSManager = FSManager()
    @ObservedObject private var observeManager: FirebaseFilesUploadingProgreessManager = FirebaseFilesUploadingProgreessManager()
    
    
    init(title: String,
         text: String,
         category: FreelanceTopic,
         devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic,
         adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic,
         designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic,
         testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic,
         recruitsCount: Int,
         languages: [LangDescriptor],
         coreSkills: String,
         previews: [UIImage]? = nil,
         imageLoader: FirebaseTemporaryImageLoaderVM, doneTrigger: Binding<Bool>, rootViewIsActive: Binding<Bool>
         ) {
        
        self._imageLoader = StateObject(wrappedValue: imageLoader)
        
        
        self.title = title
        self.text = text
        self.category = category
        
        self.recruitsCount = recruitsCount
        self.languages = languages
        self.coreSkills = coreSkills
        self.previews = previews
        
        self.devSubtopic = devSubtopic
        self.adminSubtopic = adminSubtopic
        self.designSubtopic = designSubtopic
        self.testSubtopic = testSubtopic
        
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
                    .padding(.bottom, 2)
                        
                    
//                    HStack {
//                        Text("\(recruited)/\(recruitsCount)")
//                        Image(systemName: "person")
//                            .symbolRenderingMode(.hierarchical)
//                    }
//                    .padding(.horizontal, 32)
//                    .padding()
                    

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
                            
                            Text("\(recruited)/\(recruitsCount)")
                                .foregroundColor(.white)
                                .robotoMono(.medium, 14)
                            Image(systemName: "person")
                                .symbolRenderingMode(.hierarchical)
                                .robotoMono(.light, 12, color: Color(red: 0.80, green: 0.80, blue: 0.80))
                            Divider()
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


                    // MARK: - Text
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Description")
                                .robotoMono(.semibold, 18, color: .secondary)
                                Spacer()
                        }.padding(.horizontal, 8)
                            .padding(.bottom, 4)

                        Text(LocalizedStringKey(self.text))
                    }
                    .padding(.horizontal)

                    // MARK: - Deploy Button
                    VStack {
                        Spacer()
                        HStack(alignment: .bottom) {
                            Spacer()
                            Button {
                                self.MBProgressHook.toggle()
                                self.fsmanager.createFindTeamAnnouncement(owner: self.loginUserID, title: self.title, text: self.text, category: self.category,
                                                                          devSubtopic: self.devSubtopic,
                                                                          adminSubtopic: self.adminSubtopic,
                                                                          designSubtopic: self.designSubtopic,
                                                                          testSubtopic: self.testSubtopic,
                                                                          languages: self.languages, coreSkills: self.coreSkills, previews: self.previews, recruitsCount: self.recruitsCount, observeManager: self.observeManager, completionHandler: { res in
                                    switch res {
                                    case .success(let success):
                                        print(success)
                                    case .failure(let error):
                                        //TODO: - Обработчик ошибки
                                        print(error.localizedDescription)
                                    }
                                    
                                })
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
                    }


                    Text("")
                        .frame(height: 55)
                }
            }

            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("AdditionDarkBackground"))
        }
        .sheet(isPresented: self.$doneUploading, content: {
            FindTeamPostPublishingView(onOKButtonPress: {
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

struct FindTeamPreview_Previews: PreviewProvider {
    static var previews: some View {
        FindTeamPreview(title: "Ищу команду для разработки мобильного приложения Coda", text: "Сoda - мобильное приложение соц-сеть, написанное для того, чтобы нести радость людям и облегчать поиск работы молодым кадрам в области IT, дизайна, тестирования и системного администрирования. Для написания используется только Swift, что обеспечивает нативность приложения.", category: .Development,
                        devSubtopic: .Offtop,
                        adminSubtopic: .Offtop,
                        designSubtopic: .Offtop,
                        testSubtopic: .Mobile,
                        recruitsCount: 5, languages: [.Swift, .ObjectiveC], coreSkills: "Xcode, Appcode, Combine, Networking, Firebase, JSON", imageLoader: imageLoader, doneTrigger: .constant(false), rootViewIsActive: .constant(true))
    }
}
