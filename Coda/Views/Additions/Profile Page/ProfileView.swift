//
//  ProfileView.swift
//  Coda
//
//  Created by Matoi on 30.10.2022.
//

import SwiftUI
import BottomSheet

enum BottomSheetPosition: CGFloat, CaseIterable {
    case top = 1
    case bottom = 0.8
}

var projects : [Project] = [
    Project(image: "violet", name: "Violet", description: "The maid for your iPhone"),
    Project(image: "1", name: "Matoi", description: "The notes' tint color customizer"),
    Project(image: "2", name: "Lolla", description: "MACH -O Files Dumper"),
    Project(image: "3", name: "Guraa", description: "Simple tool to develop your tweaks!")
    
]


struct ProfileView: View {
    @State var bottomSheetPosition: BottomSheetPosition = .bottom
    @State var bottomSheetTranslation : CGFloat = BottomSheetPosition.bottom.rawValue
    var bottomSheetTranslationProrated : CGFloat {
        (bottomSheetTranslation - BottomSheetPosition.bottom.rawValue) / (BottomSheetPosition.top.rawValue - BottomSheetPosition.bottom.rawValue)
    }
    var body: some View {
        
        GeometryReader { geometry in
            let screenHeight = geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
            
            ZStack {
                Image("")
                
                BottomSheetView(position: $bottomSheetPosition) {
                    
                } content: {
                    ProfileSheet(username: "MatoiDev", realName: "Matvey", realSurname: "Titor", mainLanguage: .swift, projects: projects, reputation: 103117, mates: 245, headerPosition: self.$bottomSheetTranslation)
                }
                .onBottomSheetDrag { translation in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        self.bottomSheetTranslation = translation / screenHeight
                    }
                    
                }
                .overlay {
                    VStack {
                        HStack {
                            Image("lov")
                                .resizable()
                                .frame(width: 150 - 50 * bottomSheetTranslationProrated, height: 150 - 50 * bottomSheetTranslationProrated)
                                .clipShape(Circle())
                                .offset(y: -75 * (1 - bottomSheetTranslationProrated))
                                .overlay {
                                    Circle()
                                        .strokeBorder(lineWidth: 7, antialiased: true)
                                        .foregroundColor(.black)
                                        .offset(x: geometry.size.width * 0 * (1 - bottomSheetTranslationProrated), y: -75 * (1 - bottomSheetTranslationProrated))
                                        .opacity(1 - bottomSheetTranslationProrated)
                                }
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
        ProfileView()
    }
}
