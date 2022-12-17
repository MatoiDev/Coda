//
//  PostView.swift
//  Coda
//
//  Created by Matoi on 14.12.2022.
//

import SwiftUI
import Foundation

struct PostView<Logo: View>: View {
    

    @State private var postBody: String?
    @State private var date: String?
    @State private var ownerID: String?
    @State private var postStars: [String]?
    
    @State private var postImage: UIImage?
    @State private var ownerName: String?
    
    @State private var postHasAnImage: Bool = false
    @State private var userHasLikedThisPost: Bool = false
    
    @State private var alertLog: String = ""
    @State private var showAlert: Bool = false
    
    @State private var starRotation: CGFloat = 0
    @State private var starYOffset: CGFloat = 0
    
    private var fsmanager: FSManager = FSManager()
    
    @State private var cream = 0
    
    var postID: String
    @ViewBuilder var logo: Logo
    @AppStorage("LoginUserID") var loginUserID: String = ""
    
    init(with postID: String, logo: Logo) {
        self.postID = postID
        self.logo = logo
    }

    
    private func loadPostImage(withURL url: String) async {
        await self.fsmanager.getPostImage(from: url, completion: { res in
            switch res {
            case .success(let img):
                self.postImage = img
            case .failure(let err):
                self.alertLog = err.localizedDescription
                self.postImage = UIImage(named: "default1")!
                print(self.alertLog)
                self.showAlert.toggle()
            }
        })
    }
    
    private func loadOwnerName(id: String) async {
        await self.fsmanager.getUserName(forID: id, completion: { res in
            switch res {
            case .success(let name):
                self.ownerName = name
            case .failure(let err):
                self.alertLog = err.localizedDescription
                self.showAlert.toggle()
            }
        })
    }
    
    private func loadPost() async {
        await self.fsmanager.getPost(by: self.postID) { result in
            switch result {
            case .success(let data):
                
                self.postBody = (data["body"] as! String)
                self.date = (data["date"] as! String)
                self.ownerID = (data["owner"] as! String)
                self.postStars = (data["stars"] as! [String])
                
                self.cream = self.postStars!.count
                
                self.userHasLikedThisPost = self.postStars!.contains(self.loginUserID)
                
                Task {
                    await loadOwnerName(id: self.ownerID!)
                }
                if let _ = data["image"] {
                    self.postHasAnImage = true
                    Task {
                        await self.loadPostImage(withURL: self.postID)
                    }
                }
            case .failure(let err):
                self.alertLog = err.localizedDescription
                self.showAlert.toggle()
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                if let date = self.date, let postBody = self.postBody, let stars = self.postStars {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            self.logo
                                .padding(.trailing, 4)
                                
                            VStack(alignment: .leading) {
                                if let name = self.ownerName {
                                    Text(name)
                                        .foregroundColor(.primary)
                                        .font(.custom("RobotoMono-SemiBold", size: 16))
                                } else {
                                    ProgressView()
                                }
                                Text(date)
                                    .foregroundColor(.secondary)
                                    .font(.custom("RobotoMono-Medium", size: 10))
                            }
                            Spacer()
                        }
                        
                        Text(postBody)
                            .foregroundColor(.primary)
                            .font(.custom("RobotoMono-SemiBold", size: 14))
                            .multilineTextAlignment(.leading)
                        
                        if self.postHasAnImage {
                            HStack {
                                Spacer()
                                if let image = self.postImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                } else {
                                    ProgressView()
                                }
                                Spacer()
                            }.frame(maxWidth: UIScreen.main.bounds.width - 60, maxHeight: 600)
                            
                        }
                        
                        Divider()
                            .padding(2)
                        HStack {
                            HStack {
                                Button {
                                    withAnimation {
                                        self.starRotation = 180
                                        self.starYOffset = -14
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                            withAnimation {
                                                self.starRotation = 360
                                                self.starYOffset = 0
                                            }
                                            self.starRotation = 0
                                        }
                                    }
                                    if self.userHasLikedThisPost {
                                        self.userHasLikedThisPost.toggle()
                                        self.cream -= 1
                                        self.fsmanager.unlike(profilePost: self.postID, user: self.loginUserID, owner: self.ownerID!)
                                    } else {
                                        self.userHasLikedThisPost.toggle()
                                        self.cream += 1
                                        self.fsmanager.like(profilePost: self.postID, user: self.loginUserID, owner: self.ownerID!)
                                    }
                                    self.fsmanager.getUsersData(withID: self.ownerID!)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                        self.fsmanager.getUsersData(withID: self.ownerID!)
                                    })
                                        
                                } label: {
                                    
                                    Image(systemName: self.userHasLikedThisPost ? "star.fill" : "star")
                                        .foregroundColor(.primary)
                                }
                                .rotationEffect(Angle(degrees: self.starRotation))
                                .offset(y: self.starYOffset)
                                Text("\(self.cream)")
                            }
                        }
                        
                    }
                } else {
                    ProgressView()
                }
            }.padding()

        }
        .frame(maxHeight: .infinity)
        .frame(width: UIScreen.main.bounds.width - 30)
        .background(.ultraThinMaterial)
        .background(Color("AdditionBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .task {
                await self.loadPost()
            }
            
    }
}

//struct PostView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostView(with: "dftHy1t938IXyvKbCq91rv9qPCfI7Vwd8Dl6g9f4RgueQhiazSbbKmwKLYOMraHB")
//    }
//}
