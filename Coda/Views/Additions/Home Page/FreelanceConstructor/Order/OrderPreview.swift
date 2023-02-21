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
    
    @StateObject private var server: FirebaseAvatarImageServer = FirebaseAvatarImageServer()
    
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
                        RoundedRectangle(cornerRadius: 10).strokeBorder(Color("AdditionalDarkBackground"), style: StrokeStyle.init(lineWidth: 1))
                    }
                    .padding(6)
                
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 60, height: 60)
                    .padding(4)
                    .foregroundColor(Color("AdditionalDarkBackground"))
                    
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Name")
                    Text("Surname")
                }.robotoMono(.semibold, 17)
                HStack {
                    
                    Text(self.type == .customer ? "Customer" : "Vendor")
                        .robotoMono(.medium, 16, color:.secondary)
                    
                    Divider().frame(maxHeight: 20)
                    Image(systemName: "star")
                        .rotationEffect(Angle(degrees: self.starRotationCoefficent))
                    Text("777")
                        .robotoMono(.medium, 16, color:.secondary)
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

//struct CoreSkillTag: View {
//    let text: String
//    init(withText text: String) {
//        self.text = text
//    }
//    var body: some View {
//        Text(text)
//            .robotoMono(.medium, 12)
////            .lineLimit(1)
//            .fixedSize(horizontal: true, vertical: true)
//            .padding(2)
//            .padding(.horizontal, 4)
//            .background(Color("BubbleMessageRecievedColor"))
//            .clipShape(RoundedRectangle(cornerRadius: 5))
//            .overlay {
//                RoundedRectangle(cornerRadius: 5)
//                    .stroke(Color.secondary, lineWidth: 1)
//            }
//
//    }
//}


struct OrderPreview: View {
    
    @AppStorage("UserFirstName") var userFirstName: String = ""
    @AppStorage("UserLastName") var userLastName: String = ""
    @AppStorage("UserReputation") var userReputation: String = ""
    
    var title: String
    var description: String
    var priceType: FreelanceOrderTypeReward
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
    
    private let currentDate: String = Date().today(format: "dd MMMM yyyy, HH:mm")
    private let responsesCount = 0
    private let viewsCount = 1
    
    init(title: String, description: String, priceType: FreelanceOrderTypeReward, price: String, per: SpecifiedPriceType, topic: FreelanceTopic, devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic, adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic, designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic, testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic, languages: [LangDescriptor], coreSkills: String, previews: [UIImage]? = nil, files: [URL]? = nil, imageLoader: FirebaseTemporaryImageLoaderVM) {
        
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
                            Text("Contratual price")
                        } else {
                            Text(self.price)
                            Text("₽")
                                .font(.system(size: 16).bold())
                            Text(self.per.rawValue)
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
                    }.padding(.top, -14)
                    
                    // MARK: - Tags
                    WrappingHStack(tags: self.getTags(from: self.coreSkills))
//                    .frame(maxWidth: UIScreen.main.bounds.width - 32)
                        .padding(.horizontal)
                    
                    
                    // MARK: - Business card
                    
                    BusinessCard(type: .vendor, image: self.$imageLoader.image, error: self.$imageLoader.errorLog, firstName: self.userFirstName, lastName: self.userLastName, reputation: self.userReputation)
                        .padding()
                 
                }
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("AdditionDarkBackground"), in: RoundedRectangle(cornerRadius: 25))
        }
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
var avatarURL: String = "https://firebasestorage.googleapis.com:443/v0/b/com-erast-coda.appspot.com/o/Avatars%2FqDSsjK8T5JNRcTYtDVMXT4fYqcj1?alt=media&token=e0300325-9062-4f07-86b1-fcc510f7eee0"
var imageLoader = FirebaseTemporaryImageLoaderVM(with: URL(string: avatarURL))

struct OrderPreviews_Previews: PreviewProvider {
    static var previews: some View {
        OrderPreview(title: "Write an app for iOS", description: "Violet it the tweak to customize your", priceType: .negotiated, price: "500", per: .perHour, topic: .Development, devSubtopic: .IOS, adminSubtopic: .Offtop, designSubtopic: .Offtop, testSubtopic: .Mobile, languages: [.Swift, .ObjectiveC, .Logos], coreSkills: "MVVM, Firebase, node-js, swift, Objective-C, Dart, JS", imageLoader: imageLoader)
    }
}
