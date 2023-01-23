//
//  NewsViewMain.swift
//  Coda
//
//  Created by Matoi on 23.01.2023.
//

import SwiftUI

struct NewsViewMain: View {
    
    @ObservedObject var ArticlesVM: ArticlesViewModel = ArticlesViewModel(index: 2, text: "technology")
    
    @State private var hideTabBar: Bool = false
    
    @State private var closeSafari: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                
                
                ForEach(-1..<self.ArticlesVM.articles.count, id: \.self) { articleIndex in
                    if articleIndex == -1 {
                        HStack {
                            Text("Today News").font(.custom("RobotoMono-Bold", size: 20)).foregroundColor(.primary)
                            Spacer()
                        }.listRowBackground(Color.clear)
                    } else {
                        let article: Article = self.ArticlesVM.articles[articleIndex]
                        VStack {
                            // MARK: - Title
                            Text("\(article.title)")
                                .font(.custom("RobotoMono-Bold", size: 15))
                                .padding(.all, 2)
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
                                NavigationLink(isActive: self.$closeSafari) {
                                    
                                    SafariView(url: url, viewDiactivator: self.$closeSafari)
                                        .onAppear {
                                            self.hideTabBar = true
                                        }
                                        .onDisappear {
                                            self.hideTabBar = false
                                        }.navigationBarHidden(true)
                                        .edgesIgnoringSafeArea([.top, .bottom])
                                    
                                } label: {
                                    HStack {
                                        HStack {
                                            Image(systemName: "arrowshape.left")
                                                .resizable()
                                                .rotationEffect(Angle(radians: .pi / 2))
                                                .font(.custom("RobotoMono-SemiBold", size: 20))
                                            Text("0")
                                            Image(systemName: "arrowshape.left")
                                                .resizable()
                                                .rotationEffect(Angle(radians: .pi / -2))
                                                .font(.custom("RobotoMono-SemiBold", size: 20))
                                        }.padding(.leading, 4)
                                            .fixedSize()
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            Text("\( article.source.name != nil ? article.source.name! : "")").foregroundColor(.white)
                                            if let date = article.publishedAt {
                                                Text(APIConstants.formatter.string(from: date))
                                            }
                                        }
                                        
//                                        Text("More")
                                        
                                        
                                    }.foregroundColor(.gray)
                                        .font(.custom("RobotoMono-SemiBold", size: 12))
                                }.padding(.bottom, 4)
                                
                                
                            }
                            
                        }.listRowBackground(
                            RoundedRectangle(cornerRadius: 20)
                                .background(.clear)
                                .foregroundColor(Color("AdditionBackground"))
                                .padding(
                                    EdgeInsets(
                                        top: 2,
                                        leading: 10,
                                        bottom: 2,
                                        trailing: 10
                                    )
                                )
                        )
                        .listRowSeparator(.hidden)
                        .listRowSeparatorTint(Color.clear)
                    }
                    
                }
            

            }.navigationBarHidden(true)
                .navigationBarTitle(Text("Home"))
               
            .listStyle(PlainListStyle())
                .onAppear {
                    UITableView.appearance().showsVerticalScrollIndicator = false
                    UITableView.appearance().separatorColor = UIColor.clear
                }
        }
        .publishOnTabBarAppearence(self.hideTabBar)
    }
}

