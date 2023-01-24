//
// Created by Matoi on 22.01.2023.
//

import SwiftUI


struct ArticlePostView: View {

    let article: Article
    
    @State private var postRate: Int = 0
    
    @State private var respectPost: Bool = false
    @State private var disRespectPost: Bool = false
    
    @State private var closeSafari: Bool = false
    
    @Binding var selectedArticle: Article
    @Binding var hideTabBar: Bool

    init(of article: Article, selected item: Binding<Article>, tabBarObserver: Binding<Bool>) {
        self.article = article
        self._selectedArticle = item
        self._hideTabBar = tabBarObserver
    }
    
   

    var body: some View {
        VStack {
            
            // MARK: - Title
            
            Text("\(article.title)")
                .font(.custom("RobotoMono-Bold", size: 15))
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
                .font(.custom("RobotoMono-Light", size: 11))
                .lineLimit(13)
                .foregroundColor(.white)
            Divider()
            
            // MARK: - Safari Link
            if let urlString = article.url, let url: URL = URL(string: urlString) {
                    HStack {
                        // MARK: - Post rate info
                        HStack {
                            // MARK: - Respect Button
                            Button {
                                print("respect")
                                self.postRate += self.respectPost ? -1 : 1
                                self.respectPost.toggle()
                                if self.disRespectPost == true { self.postRate += 1}
                                self.disRespectPost = false
                            } label: {
                                Image(self.respectPost ? "arrowshape.fill" : "arrowshape")
                                    .resizable()
                                    .rotationEffect(Angle(radians: .pi / 2))
                                    .font(.custom("RobotoMono-SemiBold", size: 18))
                                    .foregroundStyle(
                                            LinearGradient(colors:
                                                            self.respectPost ?  [.cyan, Color("Register2")] : [.gray]

                                                           , startPoint:  .topLeading, endPoint: .bottomTrailing)


                                    )


                            }.buttonStyle(PlainButtonStyle())

                            // MARK: - Post rate
                            Text("\(self.postRate)")
                            // MARK: - Disrespect Button
                            Button {
                                print("disrespect")
                                self.postRate += self.disRespectPost ? 1 : -1
                                self.disRespectPost.toggle()
                                if self.respectPost == true { self.postRate -= 1}
                                self.respectPost = false
                            } label: {
                                Image(self.disRespectPost ? "arrowshape.fill" : "arrowshape")
                                    .resizable()
                                    .rotationEffect(Angle(radians: .pi / -2))
                                    .font(.custom("RobotoMono-SemiBold", size: 18))
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
                    .foregroundColor(.gray)
                    .font(.custom("RobotoMono-SemiBold", size: 12))
                
            }
            
        }
        .background(NavigationLink(isActive: self.$closeSafari, destination: {
            SafariView(url: URL(string: self.selectedArticle.url!)!, viewDiactivator: self.$closeSafari)
                .navigationBarHidden(true)
                .navigationBarTitle(Text("Home"))
                .onAppear(perform: {self.hideTabBar = true})
                .onDisappear(perform: {self.hideTabBar = false})
                .ignoresSafeArea(.all)
        }, label: {EmptyView()}))
    }
}
