//
//  ProfileSheet.swift
//  Coda
//
//  Created by Matoi on 31.10.2022.
//

import SwiftUI

struct ProfileSheet: View {
    
    var username: String
    var realName: String
    var realSurname: String
    var mainLanguage: String
    var projects : [Project]
    var reputation : String
    var mates : String
    
    @EnvironmentObject var authState : AuthenticationState
    
    @State var showInfoSheet: Bool = false
    @State var showSettings: Bool = false
    
    @Binding var headerPosition : CGFloat
    
    var bottomSheetTranslationProrated : CGFloat {
        (headerPosition - BottomSheetPosition.bottom.rawValue) / (BottomSheetPosition.top.rawValue - BottomSheetPosition.bottom.rawValue)
    }
    
    
    var body: some View {
        ScrollView {
            VStack {
                // MARK: - Name & surname labels
                ZStack {
                    HStack {
                            VStack(alignment: bottomSheetTranslationProrated >= 1 ? .leading : .center) {
                                Spacer()
                                
            
                                    Text(self.username)
                                        .foregroundColor(.primary)
                                    .font(.custom("RobotoMono-Bold", size: 20))
                                    .minimumScaleFactor(0.01)
                                    .lineLimit(1)
                                
                                HStack(alignment: .top) {
                                    Text("\(self.realName) \(self.realSurname)")
                                        .font(.custom("RobotoMono-Light", size: 15).bold())
                                        .lineLimit(1)
                                }.foregroundColor(.secondary)
                                
                                Spacer()
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                    }
                    .offset(x: bottomSheetTranslationProrated * 32, y: 80 - 20 * bottomSheetTranslationProrated)
                    .padding(.horizontal, 32)
                    
                    HStack {
                        Button {
                            self.showSettings.toggle()
                        } label: {
                            Image(systemName: "gear")
                                .font(.largeTitle)
                                .symbolVariant(.fill)
                                .foregroundColor(.primary)
                                .padding()
                                .padding(.horizontal, 8)
                                .offset(y: 50 * bottomSheetTranslationProrated)
                        }
                        .fullScreenCover(isPresented: self.$showSettings) {
                            ProfileSettingsMain()
                        }

                    }.frame(maxWidth:.infinity, alignment: .trailing)
                    
                }
                
            }
            
            
            
            
            // MARK: - More Information button
            VStack {
                Divider()
                    .frame(width: UIScreen.main.bounds.width - 60)
                ProfileActionCell(withText: "More information") {
                    self.showInfoSheet.toggle()
                }
                .sheet(isPresented: self.$showInfoSheet) {
                        MoreInfoSheet()
                }
                Divider()
                    .frame(width: UIScreen.main.bounds.width - 60)
                HStack {
                    Image(systemName: "pin")
                    Text("Pinned")
                }.foregroundColor(Color.primary)
                    .font(.custom("RobotoMono-Bold", size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                
                
                // MARK: - Projects scroller
                    VStack {
                        Divider()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(projects) { project in
                                    GeometryReader { geom in
                                        ProjectCell(withProject: project)
                                            .rotation3DEffect(Angle(degrees:
                                                                        (Double(geom.frame(in: .global).minX) - 40) / -30
                                                                   ), axis: (x: 0, y: 10, z: 0))
                                        
                                    }.frame(width: 250, height: 250)
                                }
                            }.padding(.horizontal, 40)
                                .padding(.vertical, 8)
                            
                        }   .frame(width: UIScreen.main.bounds.width, height: 266)
                            .animation(.easeInOut)
                            .transition(.move(edge: .bottom))
                        Divider()
                    }
                
            }
            .offset(y: 80 + 20 * bottomSheetTranslationProrated)
            
            
        }
            .background(Color("AdditionDarkBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 40))
            .frame(height: UIScreen.main.bounds.height * 1.2, alignment: .bottom)
            .ignoresSafeArea()
        
    }
}

struct ProfileSheet_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSheet(username: "MatoiDev", realName: "Matvey", realSurname: "Titor", mainLanguage: PLanguages.swift.rawValue, projects: [
            Project(image: "violet", name: "Violet", description: "The maid for your iPhone"),
            Project(image: "1", name: "Matoi", description: "The notes' tint color customizer"),
            Project(image: "2", name: "Lolla", description: "MACH -O Files Dumper"),
            Project(image: "3", name: "Gura", description: "Simple tool to develop your tweaks!")
            
        ], reputation: "103117", mates: "245", headerPosition: .constant(0.8))
    }
}
