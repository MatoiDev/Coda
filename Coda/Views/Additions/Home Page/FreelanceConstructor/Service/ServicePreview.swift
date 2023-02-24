//
//  ServicePreview.swift
//  Coda
//
//  Created by Matoi on 24.02.2023.
//

import SwiftUI

struct ServicePreview: View {
    
    @AppStorage("LoginUserID") var loginUserID: String = ""
    @AppStorage("UserFirstName") var userFirstName: String = ""
    @AppStorage("UserLastName") var userLastName: String = ""
    @AppStorage("UserReputation") var userReputation: String = ""
    
    var title: String
    var description: String
    var priceType: FreelancePriceType
    var price: String
    var per: SpecifiedPriceType
    var topic: FreelanceTopic
    var devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic
    var adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic
    var designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic
    var testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic
    var languages: [LangDescriptor]
    var coreSkills: String
    var previews: [UIImage]?
    
   
    
    @StateObject var imageLoader: FirebaseTemporaryImageLoaderVM
    
    @Binding var doneUploading: Bool
    @Binding var rootViewIsActive: Bool
    
    @State private var MBProgressHook: Bool = false
    @State private var MBProgressInPercentages: Double = 0
    
    private let currentDate: String = Date().today(format: "dd MMMM yyyy, HH:mm")
    private let responsesCount = 0
    private let viewsCount = 1
    
    @Environment(\.dismiss) var dissmiss
    
    @ObservedObject private var fsmanager: FSManager = FSManager()
    @ObservedObject private var observeManager: FirebaseFilesUploadingProgreessManager = FirebaseFilesUploadingProgreessManager()
    
    init(title: String, description: String, priceType: FreelancePriceType, price: String, per: SpecifiedPriceType, topic: FreelanceTopic, devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic, adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic, designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic, testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic, languages: [LangDescriptor], coreSkills: String, previews: [UIImage]? = nil, imageLoader: FirebaseTemporaryImageLoaderVM, doneTrigger: Binding<Bool>, rootViewIsActive: Binding<Bool>) {
        
        self._imageLoader = StateObject(wrappedValue: imageLoader)
 
        self.title = title
        self.description = description
        self.priceType = priceType
        self.price = price
        self.per = per
        self.topic = topic
        self.devSubtopic = devSubtopic
        self.adminSubtopic = adminSubtopic
        self.designSubtopic = designSubtopic
        self.testSubtopic = testSubtopic
        self.languages = languages
        self.coreSkills = coreSkills
        self.previews = previews
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
                    
                    // MARK: - Price type
                    
                    HStack {
                        if priceType == .negotiated {
                            Text("Contractual price")
                        } else {
                            Text(self.price)
                            Text("₽")
                                .font(.system(size: 16).bold())
                            Text(LocalizedStringKey(self.per.rawValue))
                        }
                        
                    }
                    .robotoMono(.medium, 15, color: Color.mint)
                    .padding(.leading, 24)
                    .padding(.top, 2)
                    
                    // MARK: - Date, responses & views
                    
                    HStack(alignment: .center) {
                        Text(self.currentDate)
                            .padding(.leading, 24)
                            .robotoMono(.light, 12, color: Color(red: 0.80, green: 0.80, blue: 0.80))
                    
                        Divider()
                        HStack {
                            Text("\(self.responsesCount)")
                                .foregroundColor(.white)
                                .robotoMono(.medium, 14)
                            Image(systemName: "person.wave.2")
                                .robotoMono(.light, 12, color: Color(red: 0.80, green: 0.80, blue: 0.80))
                                .padding(.trailing)
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
                        .padding(4)
                        .fixedSize()
                        
         
                    }.padding(.top, -12)
                    
                    // MARK: - Tags
                    WrappingHStack(tags: self.languages.compactMap {
                        $0 == LangDescriptor.defaultValue ? nil : $0.rawValue
                    } + self.getTags(from: self.coreSkills))
                        .padding(.horizontal)
                    
                    
                    // MARK: - Business card
                    
                    BusinessCard(type: .vendor, image: self.$imageLoader.image, error: self.$imageLoader.errorLog, firstName: self.userFirstName, lastName: self.userLastName, reputation: self.userReputation)
                        .padding()
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
                    
                    // MARK: - Description
                    VStack {
                        Text(LocalizedStringKey(self.description))
                    }
                    .padding()
                
                    
                    // MARK: - Deploy Button
                    HStack {
                        Spacer()
                        Button {
                            self.MBProgressHook.toggle()
                            self.fsmanager.createFreelanceService(owner: self.loginUserID, name: self.title, description: self.description, priceType: self.priceType, price: self.price, per: self.per, topic: self.topic, devSubtopic: self.devSubtopic, adminSubtopic: self.adminSubtopic, designSubtopic: self.designSubtopic, testSubtopic: self.testSubtopic, languages: self.languages, coreSkills: self.coreSkills, previews: self.previews, observeManager: self.observeManager) { res in
                                switch res {
                                case .success(let success):
                                    print(success)
                                case .failure(let failure):
                                    print("Failure: \(failure.localizedDescription)")
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
            ServicePostPublishingView(onOKButtonPress: {
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


