//
// Created by Matoi on 22.01.2023.
//

import SwiftUI
import Combine





struct ArticlePostView: View {
    
    let article: Article
    
    @AppStorage("LoginUserID") var loginUserID: String = ""
    @AppStorage("hideTabBar") var ASHideTabBar: Bool = false
    
    @State private var postRate: Int = 0
    
    @State private var respectPost: Bool = false
    @State private var disRespectPost: Bool = false
    
    @State private var closeSafari: Bool = false
    
    @State private var image: UIImage?
    
    @State private var upvotes: [String]? // Who did like this post
    @State private var downvotes: [String]? // Who did unlike this post
    
    @State private var comments: [String]? // News post comments
    
    @Binding var selectedArticle: Article
    @Binding var hideTabBar: Bool
    
    private let fsmanager: FSManager = FSManager()
    
    init(of article: Article, selected item: Binding<Article>, tabBarObserver: Binding<Bool>) {
        self.article = article
        self._selectedArticle = item
        self._hideTabBar = tabBarObserver
    }
    
    
    
    var body: some View {
        VStack {
            
            // MARK: - Title
            
            Text("\(article.title)")
            
                .robotoMono(.bold, 15)
                .padding(.all, 2)
            
            // MARK: - Image
            
            if let _ = article.urlToImage {
                Divider()
                
                // MARK: - Image
                
                ArticleImageAsync(imageLoader: NewsImageCacher.shared.loaderFor(article: article))
                    .cornerRadius(10)
            }
            
            // MARK: - Description
            
            Text("\( article.description != nil ? article.description! : "")")

                .robotoMono(.light, 11, color: .white)
                .lineLimit(13)
                
            Divider()
            
            // MARK: - Safari Link
            if let upvotes = self.upvotes, let downvotes = self.downvotes {
                HStack {
                    // MARK: - Post rate info
                    HStack {
                        // MARK: - Respect Button
                        Button {
                            print("respect")
                            if let id = self.article.url!.dropLast().components(separatedBy: "/").last, id != "" {
                                self.fsmanager.like(newsPost: id, user: self.loginUserID)
                                self.postRate += self.respectPost ? -1 : 1
                                self.respectPost.toggle()
                                if self.disRespectPost == true { self.postRate += 1}
                                self.disRespectPost = false
                            }
                            
                            
                            
                        } label: {
                            Image(self.respectPost ? "arrowshape.fill" : "arrowshape")
                                .resizable()
                                .rotationEffect(Angle(radians: .pi / 2))
                                .robotoMono(.semibold, 18)
                                .foregroundStyle(
                                    LinearGradient(colors:
                                                    self.respectPost ?  [.cyan, Color("Register2")] : [.gray]
                                                   
                                                   , startPoint:  .topLeading, endPoint: .bottomTrailing)
                                    
                                    
                                )
                            
                            
                        }.buttonStyle(PlainButtonStyle())
                        
                        // MARK: - Post rate
                        Text("\(upvotes.count - downvotes.count)")
                        // MARK: - Disrespect Button
                        Button {
                            print("disrespect")
                            
                            if let id = self.article.url!.dropLast().components(separatedBy: "/").last, id != "" {
                                self.fsmanager.unlike(newsPost: id, user: self.loginUserID)
                                self.postRate += self.disRespectPost ? 1 : -1
                                self.disRespectPost.toggle()
                                if self.respectPost == true { self.postRate -= 1}
                                self.respectPost = false
                            }
                            
                        } label: {
                            Image(self.disRespectPost ? "arrowshape.fill" : "arrowshape")
                                .resizable()
                                .rotationEffect(Angle(radians: .pi / -2))
                                .robotoMono(.semibold, 18)
                                .foregroundStyle(
                                    LinearGradient(colors:
                                                    self.disRespectPost ? [.orange, .red, .gray] : [.gray]
                                                   
                                                   , startPoint:  .topTrailing, endPoint: .bottomLeading)
                                    
                                    
                                )
                        }.buttonStyle(PlainButtonStyle())
                        
                    }.padding(.leading, 4)
                        .fixedSize()
                    Spacer()
                    
                    Button {
                        self.selectedArticle = article
                        self.closeSafari = true
                        DispatchQueue.main.async {
                            self.hideTabBar = true
                            self.ASHideTabBar = true
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .trailing) {
                                Text("\( article.source.name != nil ? article.source.name! : "")").foregroundColor(.white)
                                if let date = article.publishedAt {
                                    Text(APIConstants.formatter.string(from: date))
                                }
                            }
                            Image(systemName: "chevron.forward")
                        }
                        
                    }.buttonStyle(PlainButtonStyle())
                }
                .robotoMono(.semibold, 12, color: .gray)
                
            }
            
        }
        
        .padding(.horizontal, 2)
        
        // MARK: - Safari View
            
        .fullScreenCover(isPresented: self.$closeSafari, content: {
            SafariView(url: URL(string: self.selectedArticle.url!)!, viewDiactivator: self.$closeSafari)
                .navigationBarHidden(true)
                .navigationBarTitle(Text("Home"))
                .onAppear(perform: {self.hideTabBar = true})
                .onDisappear(perform: {self.hideTabBar = false})
                .ignoresSafeArea(.all)
        })
        // Also working
//        .background(
//
//            NavigationLink(isActive: self.$closeSafari, destination: {
//            SafariView(url: URL(string: self.selectedArticle.url!)!, viewDiactivator: self.$closeSafari)
//                .navigationBarHidden(true)
//                .navigationBarTitle(Text("Home"))
//                .ignoresSafeArea(.all)
//        }, label: {EmptyView()}).hidden())
        
        .task {
            self.image = NewsImageCacher.shared.loaderFor(article: article).image
            
            if let id = self.article.url!.dropLast().components(separatedBy: "/").last, id != "" {
                
                self.fsmanager.newsPostIsServed(id: id) { exists in
//                    print(id, "->", exists)
                    if exists {
                        print("Document does exists")
                        self.fsmanager.getNewsPostInfo(id: id) { result in
                            switch result {
                            case .success(let dict):
                                self.upvotes = (dict["upvotes"] as! [String])
                                self.downvotes = (dict["downvotes"] as! [String])
                                
                                self.respectPost = self.upvotes!.contains(self.loginUserID)
                                self.disRespectPost = self.downvotes!.contains(self.loginUserID)
                            case .failure(let error):
                                print("Cannot load data of News Post: \(error)")
                            }
                        }
                    } else {
                        print("Creating document")
                        self.fsmanager.serveNewsPost(withID: id) { completion  in
                            switch completion {
                            case .success(_):
                                self.fsmanager.getNewsPostInfo(id: id) { postInfo in
                                    switch postInfo {
                                    case .success(let dict):
                                        self.upvotes = (dict["upvotes"] as! [String])
                                        self.downvotes = (dict["downvotes"] as! [String])
                                        
                                        self.respectPost = self.upvotes!.contains(self.loginUserID)
                                        self.disRespectPost = self.downvotes!.contains(self.loginUserID)
                                    case .failure(let error):
                                        print("Cannot load data of News Post: \(error)")
                                    }
                                }
                            case .failure(let err):
                                print("Cannot create News Post: \(err)")
                            }
                        }
                    }
                }
            }
        }
        
        // MARK: - Context Menu
        
        .contextMenu {
            // MARK: - go to the source button
            Button {
                self.selectedArticle = article
                self.closeSafari = true
                DispatchQueue.main.async {
                    self.hideTabBar = true
                }
                
            } label: {
                HStack {
                    Text("Follow")
                    Spacer()
                    Image("compass.outline")
                }
            }
            // MARK: - Copy Button
            Button {
                UIPasteboard.general.string = self.article.url
            } label: {
                HStack {
                    Text("Copy link")
                    Spacer()
                    Image(systemName: "doc.on.doc")
                }
            }
            
            // MARK: - Save image button
            if let inputImage = self.image {
                Button {
                    Vibro.trigger(.success)
                    let imageSaver = ImageSaver()
                    imageSaver.writeToPhotoAlbum(image: inputImage)
                } label: {
                    HStack {
                        Text("Save image")
                        Spacer()
                        Image(systemName: "arrow.down.circle")
                    }
                        .robotoMono(.semibold, 14)
                    
                }
                
            }
            Divider()
            
            // MARK: - Upvote button
            if self.respectPost == false {
                Button {
                    if let id = self.article.url!.dropLast().components(separatedBy: "/").last, id != "" {
                        self.fsmanager.like(newsPost: id, user: self.loginUserID)
                        self.postRate += self.respectPost ? -1 : 1
                        self.respectPost.toggle()
                        if self.disRespectPost == true { self.postRate += 1}
                        self.disRespectPost = false
                    }
                } label: {
                    HStack {
                        Text("Upvote")
                        Spacer()
                        Image("arrowshape.up")
                        
                        
                    }
                }
            }
            
            
            // MARK: - Downvote button
            if self.disRespectPost == false {
                Button {
                    if let id = self.article.url!.dropLast().components(separatedBy: "/").last, id != "" {
                        self.fsmanager.unlike(newsPost: id, user: self.loginUserID)
                        self.postRate += self.disRespectPost ? 1 : -1
                        self.disRespectPost.toggle()
                        if self.respectPost == true { self.postRate -= 1}
                        self.respectPost = false
                    }
                } label: {
                    HStack {
                        Text("Downvote")
                        Spacer()
                        Image("arrowshape.down")
                    }
                }
            }
            
        }
    }
}
