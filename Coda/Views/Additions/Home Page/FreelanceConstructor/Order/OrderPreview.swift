//
//  OrderPreviews.swift
//  Coda
//
//  Created by Matoi on 20.02.2023.
//

import SwiftUI
import Foundation
import Combine

extension Date {
    func today(format: String = "dd MMMM yyyy, HH:mm") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: Date())
        
    }
}


class FirebaseAvatarImageServer: ObservableObject {
    
    private func fetchedImageHandler(data: Data?, response: URLResponse?) throws -> UIImage {
        guard let data = data,
           let image = UIImage(data: data),
           let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else { throw URLError(.cannotParseResponse) }
        return image
    }
    
    func getImageFromServer(imageURL url: URL) -> AnyPublisher<UIImage, Error> {
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap(self.fetchedImageHandler)
            .eraseToAnyPublisher()
    }
}

 class FirebaseTemporaryImageLoaderVM: ObservableObject {
    
    @Published var image: UIImage?
    @Published var errorLog: String?
    
    private var server: FirebaseAvatarImageServer = FirebaseAvatarImageServer()
    
    var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    init(with url: URL?) {
        self.fetchImage(for: url)
    }
    
    private func fetchImage(for url: URL?) -> Void {
        if let url = url {
            server.getImageFromServer(imageURL: url)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        self.errorLog = nil
                    case .failure(let err):
                        self.errorLog = err.localizedDescription
                        self.image = nil
                    }
                } receiveValue: { [weak self] image in
                    self?.image = image
                }
                .store(in: &self.cancellables)
        } else {
            self.errorLog = URLError(.badURL).localizedDescription
        }
       

    }
}

enum BusinessCardType {
    case customer, vendor
}

struct BusinessCard: View {
    
    let type: BusinessCardType
    
    @Binding var image: UIImage?
    @Binding var error: String?
    
    let firstName: String
    let lastName: String
    
    let reputation: String
    
    @State private var starRotationCoefficent: CGFloat = 0
    
    var body: some View {
        HStack(alignment: .top) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10).strokeBorder(Color("AdditionDarkBackground"), style: StrokeStyle.init(lineWidth: 1))
                    }
                    .padding(6)
                
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 60, height: 60)
                    .padding(4)
                    .foregroundColor(Color("AdditionDarkBackground"))
                    
            }
            
            VStack(alignment: .leading) {
                HStack {
                    #if targetEnvironment(simulator)
                    Text("Name")
                    Text("Surname")
                    #else
                    Text(firstName)
                    Text(lastName)
                    #endif
                    
                }.robotoMono(.semibold, 17)
                HStack {
                    
                    Text(LocalizedStringKey(self.type == .customer ? "Customer" : "Vendor") )
                        .robotoMono(.medium, 16, color:.secondary)
                    
                    Divider().frame(maxHeight: 20)
                    Image(systemName: "star")
                        .rotationEffect(Angle(degrees: self.starRotationCoefficent))
                    #if targetEnvironment(simulator)
                    Text("777")
                        .robotoMono(.medium, 16, color:.secondary)
                    #else
                    Text(reputation)
                        .robotoMono(.medium, 16, color:.secondary)
                    #endif
                }
                .padding(.top, -8)
            }.padding([.leading])
                .padding(.top, 8)
            Spacer()
            
            
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1)) {
                self.starRotationCoefficent = 360 * 2
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BubbleMessageRecievedColor"), in: RoundedRectangle(cornerRadius: 10))
            .backgroundBlur()
    }
}


struct OrderPreview: View {
    
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
    var files: [URL]?
    
   
    
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
    
    init(title: String, description: String, priceType: FreelancePriceType, price: String, per: SpecifiedPriceType, topic: FreelanceTopic, devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic, adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic, designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic, testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic, languages: [LangDescriptor], coreSkills: String, previews: [UIImage]? = nil, files: [URL]? = nil, imageLoader: FirebaseTemporaryImageLoaderVM, doneTrigger: Binding<Bool>, rootViewIsActive: Binding<Bool>) {
        
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
        self.files = files
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
                    
                    BusinessCard(type: .customer, image: self.$imageLoader.image, error: self.$imageLoader.errorLog, firstName: self.userFirstName, lastName: self.userLastName, reputation: self.userReputation)
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
                    
                    // MARK: - Files
                    if let files = self.files, !files.isEmpty {

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
                                            width: UIScreen.main.bounds.width / 3,
                                            height: UIScreen.main.bounds.width / 3
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
                    
                    // MARK: - Deploy Button
                    HStack {
                        Spacer()
                        Button {
                            self.MBProgressHook.toggle()
                            self.fsmanager.createFreelanceOrder(owner: self.loginUserID, name: self.title, description: self.description, priceType: self.priceType, price: self.price, per: self.per, topic: self.topic, devSubtopic: self.devSubtopic, adminSubtopic: self.adminSubtopic, designSubtopic: self.designSubtopic, testSubtopic: self.testSubtopic, languages: self.languages, coreSkills: self.coreSkills, previews: self.previews, files: self.files, observeManager: self.observeManager) { res in
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
            OrderPostPublishingView(onOKButtonPress: {
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
var avatarURL: String = "https://firebasestorage.googleapis.com:443/v0/b/com-erast-coda.appspot.com/o/Avatars%2FqDSsjK8T5JNRcTYtDVMXT4fYqcj1?alt=media&token=e0300325-9062-4f07-86b1-fcc510f7eee0"
var imageLoader = FirebaseTemporaryImageLoaderVM(with: URL(string: avatarURL))

struct OrderPreviews_Previews: PreviewProvider {
    static var previews: some View {
        OrderPreview(title: "Write an app for iOS", description: "Violet it the tweak to customize your", priceType: .negotiated, price: "500", per: .perHour, topic: .Development, devSubtopic: .IOS, adminSubtopic: .Offtop, designSubtopic: .Offtop, testSubtopic: .Mobile, languages: [.Swift, .ObjectiveC, .Logos], coreSkills: "MVVM, Firebase, node-js, swift, Objective-C, Dart, JS", previews: [UIImage(named: "FreelanceServicePreview")!, UIImage(named: "FreelanceOrderPreview")!, UIImage(named: "FreelanceDevelopment")!], imageLoader: imageLoader, doneTrigger: .constant(false), rootViewIsActive: .constant(true))
    }
}
#endif
