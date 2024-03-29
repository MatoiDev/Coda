//
//  ProfileView.swift
//  Coda
//
//  Created by Matoi on 30.10.2022.
//

import SwiftUI
import BottomSheet
import CoreHaptics



struct CancelCrossButton: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body : some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .resizable()
                    .foregroundColor(.primary)
            }
        }
    }
}

enum UserMode {
    case guest, owner
}


struct ProfileView: View {
    
    @State var bottomSheetPosition: BottomSheetPositions = .bottom
    @State var bottomSheetTranslation : CGFloat = BottomSheetPositions.bottom.rawValue
    @State private var avatar: UIImage = UIImage(named: "default")!
    @State private var avatarTranslation : CGFloat = 0
    @State private var posts: [String] = []
    
    @State private var imageURL: String?
    
    @AppStorage("UserEmail") private var userEmail : String = ""
    @AppStorage("UserUsername") var userUsername: String = ""
    @AppStorage("UserFirstName") var userFirstName: String = ""
    @AppStorage("UserLastName") var userLastName: String = ""
    @AppStorage("UserMates") var userMates: String = ""
    @AppStorage("avatarURL") var avatarURL: String = ""
    @AppStorage("LoginUserAvatarID") var loginUserAvatarID: String = ""
    @AppStorage("UserReputation") var userReputation: String = ""
    @AppStorage("UserLanguage") var userLanguage: PLanguages.RawValue = ""
    @AppStorage("UserProjects") var userProjects : [String] = []
    @AppStorage("UserPosts") var userPosts : [String] = []
    
    @AppStorage("UserID") private var userID : String = ""
    @AppStorage("LoginUserID") var loginUserID: String = ""
        
    private var fsmanager: FSManager = FSManager()
    
    private let dismissable: Bool
    
    @State private var yAxisScrollViewOnBottomSheetOffset: CGFloat = CGFloat.zero
    @State private var loadAvatar : Bool = true
    @State var showInfoSheet: Bool = false
    @State var showCreatePostSheet: Bool = false
    @State private var avatarImage : AvatarImageView = AvatarImageView(urlString: nil, translation: .constant(0))
    @State private var engine: CHHapticEngine?
    
    @State private var userIDForDataTask: String
    

    @State private var userMode: UserMode!

    init(with userID: String, dismissable: Bool = false) {
        self.dismissable = dismissable
        self.userIDForDataTask = userID

        self.userMode = self.userID == self.loginUserID ? .owner : .guest
        self.userID = userID
        self.fsmanager.getUsersData(withID: self.userID)
        self.loadAvatar = true
     
       
        
//        print(self.userID == self.loginUserID, self.userMode)
//        print(self.userReputation)

    }
    
//    // TODO: Переделать способ получения и кеширования изображения через mvvm паттерн
//    func getImageURL() async {
//        while true {
//
////            fsmanager.getUsersData(withID: self.userID)
//
//            try? await Task.sleep(nanoseconds: 4 * NSEC_PER_SEC)
//
//            if self.avatarURL != "" {
//                await self.avatarImage.updateImage(url: self.avatarURL)
//                return
//            }
//        }
//    }
    
    // MARK: - Bottom Sheet Position
    var bottomSheetTranslationProrated : CGFloat {
        return (bottomSheetTranslation - BottomSheetPositions.bottom.rawValue) / (BottomSheetPositions.top.rawValue - BottomSheetPositions.bottom.rawValue)
    }
    
    // MARK: - Star Dynamic X Position
    var starPositionX : CGFloat {
        if bottomSheetTranslationProrated <= 0.5 { return -bottomSheetTranslationProrated * UIScreen.main.bounds.width / 2 }
        return -UIScreen.main.bounds.width / 2 * (1 - bottomSheetTranslationProrated) + 30
    
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            // MARK: - Screen height determination
            let screenHeight = geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
            
            ZStack {
                if self.userID != self.loginUserID || dismissable {
                    VStack {
                        HStack {
                            CancelCrossButton()
                                .frame(width: 35, height: 35)
                            Spacer()
                        }.padding()
                    }.frame(maxHeight: .infinity, alignment: .top)
                }
                

                // MARK: - Bottom Sheet View
                BottomSheetView(position: $bottomSheetPosition) {
                    
                } content: {
                    // MARK: - Profile Sheet init
                    ProfileSheet(username: self.userUsername,
                                 realName: self.userFirstName,
                                 realSurname: self.userLastName,
                                 mainLanguage: self.userLanguage,
                                 reputation: self.userReputation,
                                 mates: self.userMates,
                                 projects: self.userProjects,
                                 userMode: self.$userMode, showInfoSheet: self.$showInfoSheet,
                                 showCreatePostSheet: self.$showCreatePostSheet,
                                 yAxisOffset: self.$yAxisScrollViewOnBottomSheetOffset,
                                 headerPosition: self.$bottomSheetTranslation)
                    {
                                
                                    AvatarImageView(urlString: self.imageURL, onPost: true, translation: self.$avatarTranslation)
                                        .frame(width: 40, height: 40)
                                
                    } landAndRep: {
                    
                        if self.yAxisScrollViewOnBottomSheetOffset != 0 {
                            ZStack {
                                HStack {
                                    // MARK: - Star
                                    Image(systemName: self.bottomSheetPosition == .bottom ? "star.fill" : "star")
                                        .rotationEffect(Angle(degrees: 1080 * bottomSheetTranslationProrated))
                                    // MARK: - Reputation | Language
                                        HStack {
                                            // MARK: - Reputation
                                            Text(self.userReputation)
                                                .robotoMono(.semibold, 30 - 10 * bottomSheetTranslationProrated)
                                            // MARK: - Separator
                                            if !(self.bottomSheetTranslationProrated != 1) {
                                                Text("|")
                                                    .robotoMono(.semibold, 25)
                                                    .opacity(self.bottomSheetTranslationProrated < 1 ? 0 : 1)
                                                    .offset(y: -2)
                                            }
                                            // MARK: - Language
                                            if self.bottomSheetTranslationProrated > 0.5 {
                                                Text(language)
                                                    .offset(x: self.bottomSheetTranslationProrated != 1 ? 2500 * (1 - bottomSheetTranslationProrated) : 250 * (1 - bottomSheetTranslationProrated))
                                                    
                                            }
                                        }
                                        
                                    
                                        .robotoMono(.semibold, 20, color: self.bottomSheetTranslationProrated != 0 ? .secondary : .primary)
                                        .minimumScaleFactor(0.01)
                                    
                                        .lineLimit(1)
                                    
                                }
                                .robotoMono(.semibold, 30 - 14 * bottomSheetTranslationProrated)

                            }
                        }
                    }
                }
                // MARK: - On Dr(u)g
                .onBottomSheetDrag { translation in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        self.bottomSheetTranslation = translation / screenHeight
                        self.avatarTranslation = self.bottomSheetTranslationProrated
                    }
//                    if self.bottomSheetPosition == .bottom {
//                        Vibro.complexSuccess(engine: self.engine)
//                    } else if self.bottomSheetPosition == .top {
//                        Vibro.complexSuccess(engine: self.engine)
//                    }
                }
                
                .overlay {
                    
                    // MARK: - Reputation and language stat

                        ZStack {
                            HStack {
                                // MARK: - Star
                                Image(systemName: self.bottomSheetPosition == .bottom ? "star.fill" : "star")
                                    .rotationEffect(Angle(degrees: 1080 * bottomSheetTranslationProrated))
                                // MARK: - Reputation | Language
                                    HStack {
                                        // MARK: - Reputation
                                        Text(self.userReputation)
                                            .robotoMono(.semibold, 30 - 10 * bottomSheetTranslationProrated)
                                        // MARK: - Separator
                                        if !(self.bottomSheetTranslationProrated != 1) {
                                            Text("|")
                                                .robotoMono(.semibold, 25)
                                                .opacity(self.bottomSheetTranslationProrated < 1 ? 0 : 1)
                                                .offset(y: -2)
                                        }
                                        // MARK: - Language
                                        if self.bottomSheetTranslationProrated > 0.5 {
                                            Text(language)
                                                .offset(x: self.bottomSheetTranslationProrated != 1 ? 2500 * (1 - bottomSheetTranslationProrated) : 250 * (1 - bottomSheetTranslationProrated))
                                                
                                        }
                                    }
                                    
                                    
                                    .robotoMono(.semibold, 20, color: self.bottomSheetTranslationProrated != 0 ? .secondary : .primary)
                                    .minimumScaleFactor(0.01)
                                    .lineLimit(1)
                                
                            }
                            .offset(x: starPositionX, y: 70 * bottomSheetTranslationProrated)
                            .frame(maxWidth: 300, maxHeight: .infinity, alignment: .top)
                            .padding(8)
                            .robotoMono(.semibold, 30 - 14 * bottomSheetTranslationProrated)
                        }
                        .offset(y: -self.yAxisScrollViewOnBottomSheetOffset / 2)
                        
                        
                    
                    // MARK: - Logo
                    VStack {
                        HStack {
                            AvatarImageView(urlString: self.imageURL, translation: self.$avatarTranslation)
                        }.padding(.horizontal, 32)
                        
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                        .offset(x: -geometry.size.width / 3.2 * bottomSheetTranslationProrated, y: 125 * (1 - bottomSheetTranslationProrated))
                        .offset(y: -self.yAxisScrollViewOnBottomSheetOffset)
                }
            }
        }
        .onAppear {
            Vibro.prepareEngine(engine: &self.engine)
        }
        .task {
            print("ProfileView: Loading \(self.userIDForDataTask)")
            self.fsmanager.getUserAvatar(withID: self.userIDForDataTask, completion: { res in
                switch res {
                case .success(let imageURL):
                    print("ProfileView: i've managed to load this: \(imageURL)")
                    self.imageURL = imageURL
                case .failure(let failure):
                    print("ProfileView: Cannot load imageURL \(failure.localizedDescription)")
                }
            })
        }
        .sheet(isPresented: self.$showInfoSheet) {
            MoreInfoSheet(logo: {
                if self.avatarURL != "" {
                    AvatarImageView(urlString: self.avatarURL, onPost: true, translation: self.$avatarTranslation)
                        .frame(width: 40, height: 40)
                }
            })
        }
        .sheet(isPresented: self.$showCreatePostSheet) {
            PostCreator()
        }
    }
    
    var language: String {
        self.userLanguage
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(with: "LHJxR0mupXXymhdLdIoKkit6boB3")
    }
}

