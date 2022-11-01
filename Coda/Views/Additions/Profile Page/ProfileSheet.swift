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
    var mainLanguage: PLanguages
    var projects : [Project]
    var reputation : Int
    var mates : Int
    
    @State var showProjects: Bool = false
    
    @Binding var headerPosition : CGFloat
    
    var bottomSheetTranslationProrated : CGFloat {
        (headerPosition - BottomSheetPosition.bottom.rawValue) / (BottomSheetPosition.top.rawValue - BottomSheetPosition.bottom.rawValue)
    }
    
    
    var body: some View {
        ScrollView {
            VStack {
                // MARK: - Name & surname labels
                HStack {
                    HStack {
                        Spacer()
                            .frame(width: UIScreen.main.bounds.width / 12 * bottomSheetTranslationProrated)
                        VStack(alignment: bottomSheetTranslationProrated >= 1 ? .leading : .center) {
                            Spacer()
                            Text(self.username)
                                .foregroundColor(.primary)
                                .font(.custom("RobotoMono-Bold", size: 20))
                            HStack(alignment: .top) {
                                Text("\(self.realName) \(self.realSurname)")
                                    .font(.custom("RobotoMono-Light", size: 15).bold())
                                    .lineLimit(1)
                            }.foregroundColor(.secondary)
                            
                            Spacer()
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        Spacer()
                    }
                    .offset(x: UIScreen.main.bounds.width / 3.8, y: 80 - 20 * bottomSheetTranslationProrated)
                    .padding(.horizontal, 32)
                    .offset(y: 150)
                    Button {
                        print("Settings button has pressed!")
                    } label: {
                        Image(systemName: "gear")
                            .font(.largeTitle)
                            .symbolVariant(.fill)
                            .foregroundColor(.primary)
                            .padding()
                            .padding(.horizontal, 8)
                            .offset(y: 50 * bottomSheetTranslationProrated)
                    }

                }
                
                // MARK: - Reputations & mates
                HStack {
                    
                }
            }
            
            
            
            // MARK: - Projects show button
            VStack {
                Divider()
                    .frame(width: UIScreen.main.bounds.width - 60)
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        self.showProjects.toggle()
                    }
                    
                } label: {
                    ZStack {
                        ScrollView {}
                            .clipShape(Rectangle())
                            
                            .background(.ultraThinMaterial)
                            .clipped()
                            .frame(width: UIScreen.main.bounds.width - 30, height: 40, alignment: .center)
                            .background(.ultraThinMaterial)
                            .overlay {
                                HStack {
                                    Text("Projects")
                                        .foregroundColor(Color.primary)
                                        .font(.custom("RobotoMono-Bold", size: 15))
                                    Spacer()
                                }.padding(.horizontal, 16)
                            }.cornerRadius(15)
                    }
                    
                }

                // MARK: - Projects scroller
                if self.showProjects {
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
                            }.padding(40)
                            Spacer()
                        }   .frame(width: UIScreen.main.bounds.width, height: 266)
                            .background(Color.secondary)
                            .animation(.easeInOut)
                            .transition(.move(edge: .bottom))
                        Divider()
                    }
                }
            }
            .offset(y: 80 + 20 * bottomSheetTranslationProrated)
            

        }.background(.ultraThinMaterial)
            .background(Color("BackgroundColor1"))
            .clipShape(RoundedRectangle(cornerRadius: 40))
            .frame(height: UIScreen.main.bounds.height * 1.2, alignment: .bottom)
            .ignoresSafeArea()
        
    }
}

struct ProfileSheet_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSheet(username: "MatoiDev", realName: "Matvey", realSurname: "Titor", mainLanguage: .swift, projects: [
            Project(image: "violet", name: "Violet", description: "The maid for your iPhone"),
            Project(image: "1", name: "Matoi", description: "The notes' tint color customizer"),
            Project(image: "2", name: "Lolla", description: "MACH -O Files Dumper"),
            Project(image: "3", name: "Guraa", description: "Simple tool to develop your tweaks!")
            
        ], reputation: 103117, mates: 245, headerPosition: .constant(1.0))
    }
}
