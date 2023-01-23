//
//  MoreInfoSheet.swift
//  Coda
//
//  Created by Matoi on 19.11.2022.
//

import SwiftUI

struct MoreInfoSheet<Logo: View>: View {
    
    @AppStorage("UserBio") var userBio : String = ""
    @AppStorage("UserPosts") var userPosts : [String] = []
    @AppStorage("UserProjects") var userProjects : [String] = []
    @AppStorage("UserRegisterDate") var userRegisterDate: String = ""
    
    @State private var bioOffset: CGFloat = 125 * 3
    @State private var dateOffset: CGFloat = 100 * 3
    @State private var projectsOffset: CGFloat = 75 * 3
    @State private var postsOffset: CGFloat = 50 * 3
    
    @ViewBuilder var logo: Logo
    
    var body: some View {
        List {
            Section {
                VStack {
                    Text("Information")
                    Divider()
                    HStack(alignment: .top) {
                        Image(systemName: "c.circle")
                            .foregroundColor(.secondary)
                            .font(.custom("RobotoMono-Bold", size: 15))
                        Text(self.userBio.isEmpty ? "..." : self.userBio)
                            .offset(x: self.bioOffset)
                           Spacer()
                    }.padding(.top, 16)
                    .font(.custom("RobotoMono-SemiBold", size: 13))
                    .onAppear {
                        withAnimation(Animation.easeOut(duration: 0.5)) {
                                self.bioOffset = 0
                                self.dateOffset = 0
                                self.postsOffset = 0
                                self.projectsOffset = 0
                        }
                    }
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                            .font(.custom("RobotoMono-Bold", size: 15))
                        Text(self.userRegisterDate)
                            .offset(x: self.dateOffset)
                           Spacer()
                    }.padding(.top, 4)
                    .font(.custom("RobotoMono-SemiBold", size: 13))
                    
                    HStack {
                        Image(systemName: "shippingbox")
                            .foregroundColor(.secondary)
                            .font(.custom("RobotoMono-Bold", size: 15))
                        Text(self.userProjects.count > 0 ? "Projects: \(self.userProjects.count)" : "No projects")
                            .offset(x: self.projectsOffset)
                           Spacer()
                    }.padding(.top, 4)
                    .font(.custom("RobotoMono-SemiBold", size: 13))
                    
                    HStack {
                        Image(systemName: "list.dash.header.rectangle")
                            .foregroundColor(.secondary)
                            .font(.custom("RobotoMono-Bold", size: 15))
                        Text(self.userPosts.count > 0 ? "Posts: \(self.userPosts.count)" : "No posts")
                            .offset(x: self.postsOffset)
                           Spacer()
                    }.padding(.top, 4)
                    .font(.custom("RobotoMono-SemiBold", size: 13))
                    
                    Divider().padding()
                }.frame(maxHeight: .infinity, alignment: .top)
                    .foregroundColor(.primary)
                    .font(.custom("RobotoMono-Bold", size: 20))
            }.listRowBackground(Color.clear)
                .padding(.horizontal, -8)
        
            ForEach(self.userPosts, id: \.self) { post in
                Section {
                    PostView(with: post, logo: self.logo)
                }.listRowInsets(EdgeInsets())
                    .buttonStyle(PlainButtonStyle())
            }

        }
        
        
    }
}

