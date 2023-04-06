//
//  BusinessCardAsync.swift
//  Coda
//
//  Created by Matoi on 06.04.2023.
//

import SwiftUI

struct BusinessCardAsync: View {
    
    
    
    let type: BusinessCardType
    
    let userID: String
    
    let time: String?
    
    init(withType type: BusinessCardType, userID: String, time: String? = nil) {
        self.type = type
        self.userID = userID
        self.time = time
    }
    
    @State private var avatarURL: String? = nil
    @State private var firstName: String? = nil
    @State private var secondName: String? = nil
    
    @State private var reputation: Int? = nil
    
    
    private let fsmanager: FSManager = FSManager()
    
    @State private var starRotationCoefficent: CGFloat = 0

    var body: some View {
        ZStack {
//            RoundedRectangle(cornerRadius: 15)
//                .frame(maxWidth: .infinity)
//                .foregroundColor(Color("AdditionBackground"))
            Group {
                if let firstName = self.firstName, let secondName = self.secondName, let reputation = self.reputation {
                    HStack(alignment: .top) {
                        CachedImageView(with: self.avatarURL, for: .Default)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10).strokeBorder(Color("AdditionDarkBackground"), style: StrokeStyle.init(lineWidth: 1))
                            }
                            .padding(6)
                        VStack(alignment: .leading) {
                            HStack {
                                #if targetEnvironment(simulator)
                                Text("Name")
                                Text("Surname")
                                #else
                                Text(firstName)
                                Text(secondName)
                                #endif
                                
                            }.robotoMono(.semibold, 17)
                            HStack {
                                switch self.type {
                                case .customer:
                                    Text(LocalizedStringKey("Customer"))
                                        .robotoMono(.medium, 16, color:.secondary)
                                case .vendor:
                                    Text(LocalizedStringKey("Vendor"))
                                        .robotoMono(.medium, 16, color:.secondary)
                                case .company:
                                    Text(LocalizedStringKey("Company"))
                                        .robotoMono(.medium, 16, color:.secondary)
                                case .author:
                                    Text(LocalizedStringKey("Author"))
                                        .robotoMono(.medium, 16, color:.secondary)
                                }
                                Divider().frame(maxHeight: 20)
                                Image(systemName: "star")
                                    .foregroundColor(.yellow)
                                    .rotationEffect(Angle(degrees: self.starRotationCoefficent))
                                #if targetEnvironment(simulator)
                                Text("777")
                                    .robotoMono(.medium, 16, color:.secondary)
                                #else
                                Text("\(reputation)")
                                    .robotoMono(.medium, 16, color:.secondary)
                                #endif
                            }
                            .padding(.top, -8)
                        }.padding([.leading])
                            .padding(.top, 8)
                        Spacer()
                        
                        
                    }
                } else {
                    EmptyView()
                }
            }
        }
//        .overlay(content: {
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(LinearGradient(colors: [.white, .gray], startPoint: .topLeading, endPoint: .bottomLeading), lineWidth: 0.2)
//        })
//        
        .task {
           await self.fsmanager.getUserInfo(forID: self.userID) { res in
                switch res {
                case .success(let userData):
                    
                    self.avatarURL = (userData["avatarURL"] as! String)
                    self.firstName = (userData["name"] as! String)
                    self.secondName = (userData["surname"] as! String)
                    self.reputation = (userData["reputation"] as! Int)
                    
                case .failure(let failure):
                    print("BusinessCardAsync: \(failure.localizedDescription)")
                }
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 2)) {
                self.starRotationCoefficent = 360 * 2
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BubbleMessageRecievedColor"), in: RoundedRectangle(cornerRadius: 10))
            .backgroundBlur()
    }
}


//struct BusinessCardAsync_Previews: PreviewProvider {
//    static var previews: some View {
//        BusinessCardAsync()
//    }
//}
