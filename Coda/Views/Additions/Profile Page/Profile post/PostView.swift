//
//  PostView.swift
//  Coda
//
//  Created by Matoi on 14.12.2022.
//

import SwiftUI
import Foundation
import CoreHaptics

//struct HTMLText: UIViewRepresentable {
//
//   let html: String
//
//   func makeUIView(context: UIViewRepresentableContext<Self>) -> UILabel {
//        let label = UILabel()
//        DispatchQueue.main.async {
//            let data = Data(self.html.utf8)
//            if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
//                label.attributedText = attributedString
//            }
//        }
//
//        return label
//    }
//
//    func updateUIView(_ uiView: UILabel, context: Context) {}
//}

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
    @State private var showPostEditor: Bool = false
    
    @State private var starRotation: CGFloat = 0
    @State private var starYOffset: CGFloat = 0
    
    @State private var engine: CHHapticEngine?
    
    @ObservedObject var model: AppConfiguration = AppConfiguration()
    
    private var fsmanager: FSManager = FSManager()
    
    @State private var cream = 0
    
    var postID: String
    @ViewBuilder var logo: Logo
    
    @AppStorage("UserID") private var userID : String = ""
    @AppStorage("LoginUserID") private var loginUserID: String = ""
    
    init(with postID: String, logo: Logo) {
        self.postID = postID
        self.logo = logo
        self.model.reloadView()
        print("refreshView")
    }
    
    // MARK: - Load Post Image
    private func loadPostImage(withURL url: String) async {
        await self.fsmanager.getPostImage(from: url, completion: { res in
            switch res {
            case .success(let img):
                self.postImage = img
            case .failure(let err):
                self.alertLog = err.localizedDescription
                self.postImage = UIImage(named: "default1")!
                print(self.alertLog, "______________")
                self.showAlert.toggle()
            }
        })
    }
    
    // MARK: - Load Author's Name
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
    
    // MARK: - Load func
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
                } else {
                    self.postHasAnImage = false
                    self.postImage = nil
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
                if let date = self.date, let postBody = self.postBody, let _ = self.postStars {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            self.logo
                                .padding(.trailing, 4)
                            
                            VStack(alignment: .leading) {
                                if let name = self.ownerName {
                                    // MARK: - Name
                                    Text(name)
                                        
                                        .robotoMono(.semibold, 16)
                                        
                                } else {
                                    ProgressView()
                                }
                                // MARK: - Date
                                Text(date)
                                    .robotoMono(.medium, 10, color: .secondary)
                            }
                            Spacer()
                            // MARK: - Ellipses menu
                            Menu {
                                if self.userID == self.loginUserID {
                                    Button {
                                        self.showPostEditor.toggle()
                                        Vibro.complexSuccess(engine: self.engine)
                                    } label: {
                                        HStack {
                                            Text("Edit Post")
                                            Image(systemName: "square.and.pencil")
                                        }
                                    }
                                    Button {
                                        withAnimation {
                                            self.starRotation = 180
                                            self.starYOffset = -14
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                                if self.userHasLikedThisPost {
                                                    Vibro.trigger(.success)
                                                } else {
                                                    Vibro.complexSuccess(engine: self.engine)
                                                }
                                                
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
                                        
                                    } label: {
                                        HStack {
                                            Text(self.userHasLikedThisPost ? "Unlike this post" : "Like this post")
                                            Spacer()
                                            Image(systemName: !self.userHasLikedThisPost ? "star.fill" : "star")
                                        }
                                        .robotoMono(.semibold, 14)
                                    }
                                    Divider()
                                    Button(role: .destructive) {
                        
                                        self.fsmanager.remove(post: self.postID, userID: self.userID) { result in
                                            switch result {
                                            case .success(let success):
                                                Vibro.trigger(.success)
                                                print(success)
                                            case .failure(let failure):
                                                print(failure)
                                                Vibro.trigger(.error)
                                                self.alertLog = failure.localizedDescription
                                                self.showAlert.toggle()
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text("Delete Post")
                                            Image(systemName: "trash")
                                        }
                                        .robotoMono(.semibold, 14, color: .red)
                                        
                                    }
                                } else {
                                    if self.postImage != nil {
                                        Button {
                                            guard let inputImage = self.postImage else {
                                                Vibro.trigger(.error)
                                                return
                                            }
                                            Vibro.trigger(.success)
                                            let imageSaver = ImageSaver()
                                            imageSaver.writeToPhotoAlbum(image: inputImage)
                                        } label: {
                                            HStack {
                                                Text("Save photo")
                                                Spacer()
                                                Image(systemName: "arrow.down.circle")
                                            }
                                            .robotoMono(.semibold, 14)
                                        }
                                    }
                                    Button {
                                        withAnimation {
                                            self.starRotation = 180
                                            self.starYOffset = -14
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                                if self.userHasLikedThisPost {
                                                    Vibro.trigger(.success)
                                                } else {
                                                    Vibro.complexSuccess(engine: self.engine)
                                                }
                                                
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
                                        
                                    } label: {
                                        HStack {
                                            Text(self.userHasLikedThisPost ? "Unlike this post" : "Like this post")
                                            Spacer()
                                            Image(systemName: !self.userHasLikedThisPost ? "star.fill" : "star")
                                        }.robotoMono(.semibold, 14)
                                    }
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle.fill")
                                    .resizable()
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundColor(.primary)
    
                                    
                            }.onTapGesture {
                                Vibro.complexSuccess(engine: self.engine)
                            }
                            .frame(width: 25, height: 25)
                                
                            
                            
                        }
                        // MARK: - Post Body
//                        HTMLText(html: postBody)
                        Text(LocalizedStringKey(postBody))
                            .robotoMono(.semibold, 14)
                            .multilineTextAlignment(.leading)
                        
                        if self.postHasAnImage {
                            HStack {
                                Spacer()
                                if let image = self.postImage {
                                    // MARK: - Post Image
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .contextMenu {
                                            Button {
                                                guard let inputImage = self.postImage else {
                                                    Vibro.trigger(.error)
                                                    return
                                                }
                                                Vibro.trigger(.success)
                                                let imageSaver = ImageSaver()
                                                imageSaver.writeToPhotoAlbum(image: inputImage)
                                            } label: {
                                                HStack {
                                                    Text("Save photo")
                                                    Spacer()
                                                    Image(systemName: "arrow.down.circle")
                                                }
                                                .robotoMono(.semibold, 14)
                                            }
                                        }
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
                                // MARK: - Like Button
                                Button {
                                    
                                    withAnimation {
                                        self.starRotation = 180
                                        self.starYOffset = -14
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//
                                            if self.userHasLikedThisPost {
                                                Vibro.trigger(.success)
                                            } else {
                                                Vibro.complexSuccess(engine: self.engine)
                                            }
                                            
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
        .frame(maxWidth: UIScreen.main.bounds.width - 30)
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .onAppear {
            Vibro.prepareEngine(engine: &self.engine)
        }
        .task {
            await self.loadPost()
        }
        .sheet(isPresented: self.$showPostEditor) {
            PostCreator(postBody: self.postBody ?? "HUI", postImage: self.postImage, postID: self.postID, presentAsARedactor: true) {
                await self.loadPost()
            }
        }
    }
}
