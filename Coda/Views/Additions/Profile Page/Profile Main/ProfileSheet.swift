//
//  ProfileSheet.swift
//  Coda
//
//  Created by Matoi on 31.10.2022.
//

import SwiftUI

struct ProfileSheet<Logo: View, LanguageAndReputation: View>: View {
    
    var username: String
    var realName: String
    var realSurname: String
    var mainLanguage: String
    var reputation : String
    var mates : String
    
    var projects : [String]
    
    @EnvironmentObject var authState : AuthenticationState
    
    @Binding var userMode : UserMode?
    
    @State var showSettings: Bool = false
    @Binding var showInfoSheet: Bool
    @Binding var showCreatePostSheet: Bool
    
    @Binding var yAxisOffset: CGFloat
    
    @State var forceUpdateScroll: Bool = false
    @State private var showPosts: Bool = false
    
    @Binding var headerPosition : CGFloat
    
    
    @AppStorage("UserProjects") var userProjects : [String] = []
    @AppStorage("UserPosts") var userPosts : [String] = []
    @AppStorage("Updater") private var updater: Bool = false
    
    @AppStorage("UserID") private var userID : String = ""
    @AppStorage("LoginUserID") var loginUserID: String = ""

    @ViewBuilder var logo: Logo
    @ViewBuilder var landAndRep: LanguageAndReputation
    
    var bottomSheetTranslationProrated : CGFloat {
        (headerPosition - BottomSheetPositions.bottom.rawValue) / (BottomSheetPositions.top.rawValue - BottomSheetPositions.bottom.rawValue)
        
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack {
                // MARK: - Name & surname labels
                ZStack {
                    HStack {
                        VStack(alignment: bottomSheetTranslationProrated >= 1 ? .leading : .center) {
                            Spacer()
                            
                            
                            Text(self.username)
                                .robotoMono(.bold, 20)
                                .minimumScaleFactor(0.01)
                                .lineLimit(1)
                            
                            HStack(alignment: .top) {
                                Text("\(self.realName) \(self.realSurname)")
//                                    .robotoMono(.light, 15)
                                    .font(.custom("RobotoMono-Light", size: 15).bold())
                                    .lineLimit(1)
                            }.foregroundColor(.secondary)
                            
                            
                            Spacer()
                            Spacer()
                            //                                landAndRep.padding(.horizontal, 0)
                            
                        }
                        .padding(.horizontal, 8)
                    }
                    .offset(x: bottomSheetTranslationProrated * 32, y: 80 - 20 * bottomSheetTranslationProrated)
                    .padding(.horizontal, 32)
                    if self.userID == self.loginUserID {
                        HStack {
                            Button {
                                self.showSettings.toggle()
                            } label: {
                                Image(systemName: "gearshape")
                                    .font(.largeTitle)
    //                                .symbolVariant(.fill)
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
                
            }.background(GeometryReader {
                Color.clear.preference(key: ViewOffsetKey.self,
                                       value: -$0.frame(in: .named("scroll")).origin.y)
            })
            // Scrollview offset
            .onPreferenceChange(ViewOffsetKey.self) {
                print("offset >> \($0)")
                self.yAxisOffset = $0 < 0 ? 0 : $0 * 2
                
            }
            
            
            
            
            // MARK: - More Information button
            VStack {
                Divider()
                    .frame(width: UIScreen.main.bounds.width - 60)
                ProfileActionCell(withText: "More information") {
                    self.showInfoSheet.toggle()
                    
                }
                //                Divider()
                .frame(width: UIScreen.main.bounds.width - 60)
                
                
                
                // MARK: - Projects scroller
                if self.userProjects.count > 0 {
                    HStack {
                        Image(systemName: "pin")
                        Text("Pinned")
                    }.robotoMono(.bold, 17)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                    VStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(0..<self.userProjects.count) { index in
                                    GeometryReader { geom in
                                        if let projID = self.userProjects[safe: index] {
                                            ProjectCell(withProjectID: projID).equatable()
                                                .rotation3DEffect(Angle(degrees:
                                                                            (Double(geom.frame(in: .global).minX) - 40) / -30
                                                                       ), axis: (x: 0, y: 10, z: 0))
                                        }
                                    }.frame(width: 250, height: 250)
                                }
                            }.padding(.horizontal, 40)
                                .padding(.vertical, 8)
                            
                        }   .frame(width: UIScreen.main.bounds.width, height: 266)
                            .animation(.easeInOut)
                            .transition(.move(edge: .bottom))
                    }
                }
                
                // MARK: - Posts
                HStack {
                    Image(systemName: "list.dash.header.rectangle")
                    Text("Posts")
                }.robotoMono(.bold, 17)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                if self.userID == self.loginUserID {
                    ProfileActionCell(withText: "Create Post") {
                        self.showCreatePostSheet.toggle()
                    }.padding(.bottom, 16)
                }
                    
                    
                
                    
                
                    if self.userPosts.count == 0 {
                        HStack {
                            Spacer()
                            Text("No posts")
                                .robotoMono(.bold, 17, color: .secondary)
                            Spacer()
                            
                        }
                    } else {
                        VStack {
                            HStack {
                                Spacer()
                                Text("\(self.userPosts.count) posts")
                                    .robotoMono(.bold, 17, color: .secondary)
                                Spacer()                                
                            }
                            Spacer()
                            Spacer()
                            Text("")
                        }.frame(height:400)
                        
                          
                    }
            }
            .offset(y: 80 + 20 * bottomSheetTranslationProrated)
        }.onAppear {
//            UIScrollView.appearance().bounces = false
            UIScrollView.appearance().showsVerticalScrollIndicator = false
            
        }
        .coordinateSpace(name: "scroll")
        .background(Color("AdditionDarkBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 40))
        .frame(height: UIScreen.main.bounds.height * 1.2, alignment: .bottom)
        .ignoresSafeArea()
        
    }
}
