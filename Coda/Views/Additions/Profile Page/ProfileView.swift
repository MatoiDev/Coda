//
//  ProfileView.swift
//  Coda
//
//  Created by Matoi on 30.10.2022.
//

import SwiftUI
import BottomSheet



var projects : [Project] = [
    Project(image: "violet", name: "Violet", description: "The maid for your iPhone"),
    Project(image: "1", name: "Matoi", description: "The notes' tint color customizer"),
    Project(image: "2", name: "Lolla", description: "MACH -O Files Dumper"),
    Project(image: "3", name: "Guraa", description: "Simple tool to develop your tweaks!")
    
]

func stringToDict(string dict: String) -> Dictionary<String, String> {
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
    
    private var fsmanager: FSManager = FSManager()
    @State private var loadAvatar : Bool = true
    
    var userID: String
    
    private var userDataFormatted : Dictionary<String, String> = Dictionary<String, String>()
    
    @AppStorage("userData") var userData : String = ""
    
    init(with userID: String) {
        
        self.userID = userID
        fsmanager.getUsersData(withID: self.userID)
        userDataFormatted = stringToDict(string: self.userData)
        
        self.loadAvatar = true
        
    }
    
    // MARK: - Bottom Sheet Position
    var bottomSheetTranslationProrated : CGFloat {
        (bottomSheetTranslation - BottomSheetPosition.bottom.rawValue) / (BottomSheetPosition.top.rawValue - BottomSheetPosition.bottom.rawValue)
    }
    
    // MARK: - Star Dynamic X Position
    var starPositionX : CGFloat {
        if bottomSheetTranslationProrated <= 0.5 { return bottomSheetTranslationProrated * 30 - 2 }
        return 30 * (1 - bottomSheetTranslationProrated)
    
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            // MARK: - Screen height determination
            let screenHeight = geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
            
            ZStack {
//                Image("")
                // MARK: - Bottom Sheet View
                BottomSheetView(position: $bottomSheetPosition) {
                    
                } content: {
                    // MARK: - Profile Sheet init
                    ProfileSheet(username: self.userDataFormatted["username"] ?? "username", realName: self.userDataFormatted["name"] ?? "name" , realSurname: self.userDataFormatted["surname"] ?? "surname", mainLanguage: self.userDataFormatted["language"] ?? PLanguages.swift.rawValue, projects: projects, reputation: self.userDataFormatted["reputation"] ?? "0", mates: self.userDataFormatted["mates"] ?? "0", headerPosition: self.$bottomSheetTranslation)
                }
                .onBottomSheetDrag { translation in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        self.bottomSheetTranslation = translation / screenHeight
                        self.avatarTranslation = self.bottomSheetTranslationProrated
                    }

                }
                
                .overlay {
                    // MARK: - Reputation and language stat
                    HStack {
                        // MARK: - star
                        Image(systemName: self.bottomSheetPosition == .bottom ? "star.fill" : "star")
                            .rotationEffect(Angle(degrees: 1080 * bottomSheetTranslationProrated))
                            .offset(x: -10 * starPositionX, y: 84 * bottomSheetTranslationProrated)
                            .offset(x: self.bottomSheetPosition == .top ? 30 : 0)
                        HStack {
                            // MARK: - reputation
                            Text(self.userDataFormatted["reputation"] ?? "777")
                                .offset(x: -10 * starPositionX, y: 84 * bottomSheetTranslationProrated)
                                .offset(x: self.bottomSheetPosition == .top ? 30 : 0)
                            if self.bottomSheetTranslationProrated == 1 {
                                // MARK: - separator
                                Text("|")
                                    .offset(x: -10 * starPositionX, y: 84 * bottomSheetTranslationProrated)
                                    .offset(x: self.bottomSheetPosition == .top ? 30 : 0)
                                    .opacity(self.bottomSheetTranslationProrated < 1 ? self.bottomSheetTranslationProrated - 0.8 : 1)
                            }
                            // MARK: - language
                            Text(self.userDataFormatted["language"] ?? "Objective-C")
                                .offset(y: 84)
                                .offset(x: self.bottomSheetPosition == .top ? 30 : 250 * (1 - bottomSheetTranslationProrated))
                                .opacity(self.bottomSheetTranslationProrated < 1 ? self.bottomSheetTranslationProrated - 0.8 : 1)
                                .font(.custom("RobotoMono-SemiBold", size: 14))
                        }
                    }.font(.custom("RobotoMono-SemiBold", size: 30 - 14 * bottomSheetTranslationProrated))
                        .foregroundColor(self.bottomSheetPosition == .top ? .secondary : .primary)
                        .frame(maxHeight: .infinity, alignment: .top)
                        
                    
                    // MARK: - Logo
                    VStack {
                        HStack {
            
                            AvatarImageView(urlString: self.userDataFormatted["avatarURL"], translation: self.$avatarTranslation)
                            Spacer()
                        }.padding(.horizontal, 32)
                        
                    }.frame(maxHeight: .infinity, alignment: .top)
                        .offset(x: geometry.size.width / 4.48 * (1 - bottomSheetTranslationProrated), y: 125 * (1 - bottomSheetTranslationProrated))
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(with: "LHJxR0mupXXymhdLdIoKkit6boB3")
    }
}

