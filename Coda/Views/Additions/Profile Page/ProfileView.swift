//
//  ProfileView.swift
//  Coda
//
//  Created by Matoi on 30.10.2022.
//

import SwiftUI
import BottomSheet



var projects : [Project] = [
    Project(image: "deCard", name: "deCard", description: "Simple Apple Pay cards customizer that has UI"),
    Project(image: "Chorder", name: "Chorder", description: "A useful determinant of guitar chords"),
    Project(image: "Violet", name: "Violet", description: "The maid for your iPhone"),
    Project(image: "Matoi", name: "Matoi", description: "Notes tintColor customizer")
    
]

func stringToDict(string dict: String) -> Dictionary<String, String> {
    print(dict)
    let dict: String = String(String(dict.dropFirst()).dropLast())
    var res: Dictionary<String, String> = Dictionary<String, String>()

    for item in dict.split(separator: ",") {
        let items = item.split(separator: ":")
        var key = String(String(items[0].dropFirst()).dropLast())
        if key[key.startIndex] == "\"" {
            key = String(key.dropFirst())
        }

        var value: String = String(items[1])
        if value[value.startIndex] == " " {
            value = String(value.dropFirst())
        }
        if value == "https" {
            print(items[2])
            value =  items[1...].joined(separator: ":")
            if value[value.startIndex] == " " {
                value = String(value.dropFirst())
            }
        }
        res[key] = value
    }
    return res
}


struct ProfileView: View {
    @State var bottomSheetPosition: BottomSheetPosition = .bottom
    @State var bottomSheetTranslation : CGFloat = BottomSheetPosition.bottom.rawValue
    @State private var avatar: UIImage = UIImage(named: "default")!
    @State private var avatarTranslation : CGFloat = 0
    
    @AppStorage("UserEmail") private var userEmail : String = ""
    @AppStorage("UserUsername") var userUsername: String = ""
    @AppStorage("UserFirstName") var userFirstName: String = ""
    @AppStorage("UserLastName") var userLastName: String = ""
    @AppStorage("UserMates") var userMates: String = ""
    @AppStorage("avatarURL") var avatarURL: String = ""
    @AppStorage("UserReputation") var userReputation: String = ""
    @AppStorage("UserLanguage") var userLanguage: PLanguages.RawValue = ""
    
    @AppStorage("UserID") private var userID : String = ""
        
    private var fsmanager: FSManager = FSManager()
    @State private var loadAvatar : Bool = true

    init(with userID: String) {
        
        self.userID = userID
        fsmanager.getUsersData(withID: self.userID)
        self.loadAvatar = true
        
    }
    
    // MARK: - Bottom Sheet Position
    var bottomSheetTranslationProrated : CGFloat {
        return (bottomSheetTranslation - BottomSheetPosition.bottom.rawValue) / (BottomSheetPosition.top.rawValue - BottomSheetPosition.bottom.rawValue)
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

                // MARK: - Bottom Sheet View
                BottomSheetView(position: $bottomSheetPosition) {
                    
                } content: {
                    // MARK: - Profile Sheet init
                    ProfileSheet(username: self.userUsername, realName: self.userFirstName , realSurname: self.userLastName, mainLanguage: self.userLanguage, projects: projects, reputation: self.userReputation, mates: self.userMates, headerPosition: self.$bottomSheetTranslation)
                }
                // MARK: - On Dr(u)g
                .onBottomSheetDrag { translation in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        self.bottomSheetTranslation = translation / screenHeight
                        self.avatarTranslation = self.bottomSheetTranslationProrated
                    }
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
                                        .font(.custom("RobotoMono-SemiBold", size: 30 - 10 * bottomSheetTranslationProrated))
                                    // MARK: - Separator
                                    if !(self.bottomSheetTranslationProrated != 1) {
                                        Text("|")
                                            .font(.custom("RobotoMono-SemiBold", size: 25))
                                            .opacity(self.bottomSheetTranslationProrated < 1 ? 0 : 1)
                                            .offset(y: -2)
                                    }
                                    // MARK: - Language
                                    if self.bottomSheetTranslationProrated > 0.5 {
                                        Text(language)
                                            .offset(x: self.bottomSheetTranslationProrated != 1 ? 2500 * (1 - bottomSheetTranslationProrated) : 250 * (1 - bottomSheetTranslationProrated))
                                            
                                    }
                                }
                                
                                .font(.custom("RobotoMono-SemiBold", size: 20))
                                .minimumScaleFactor(0.01)
                                .foregroundColor(self.bottomSheetTranslationProrated != 0 ? .secondary : .primary)
                                .lineLimit(1)
                            
                        }.offset(x: starPositionX, y: 70 * bottomSheetTranslationProrated)
                        .frame(maxWidth: 300, maxHeight: .infinity, alignment: .top)
                        .padding(8)
                        .font(.custom("RobotoMono-SemiBold", size: 30 - 14 * bottomSheetTranslationProrated))
                    }
                        
                    
                    // MARK: - Logo
                    VStack {
                        HStack {
            
                            AvatarImageView(urlString: self.avatarURL, translation: self.$avatarTranslation)
                            
                        }.padding(.horizontal, 32)
                        
                    }.frame(maxHeight: .infinity, alignment: .top)
                        .offset(x: -geometry.size.width / 3.2 * bottomSheetTranslationProrated, y: 125 * (1 - bottomSheetTranslationProrated))
                }
            }
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

