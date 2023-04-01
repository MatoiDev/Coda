//
//  NewsViewMain.swift
//  Coda
//
//  Created by Matoi on 23.01.2023.
//

import SwiftUI

enum NewsApiCategories: String {
    case business
    case entertainment
    case general
    case health
    case science
    case sports
    case technology
}

struct NewsViewMain: View {
    
    @ObservedObject var ArticlesVM: ArticlesViewModel = ArticlesViewModel(index: 2, text: NewsApiCategories.technology.rawValue)
    
    @State private var hideTabBar: Bool = false
    
    @State private var selectedArticle: Article = Article.SOLID
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    if !Reachability.isConnectedToNetwork() || self.ArticlesVM.articles.count == 0 {
                        ArticleStubView()
                            .buttonStyle(PlainButtonStyle())
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 20)
                                .background(.clear)
                                .foregroundColor(Color("AdditionBackground"))
                                .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                        )
                        
                        .listRowSeparator(.hidden)
                        .listRowSeparatorTint(Color.clear)
                        ArticleStubView()
                            .buttonStyle(PlainButtonStyle())
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 20)
                                .background(.clear)
                                .foregroundColor(Color("AdditionBackground"))
                                .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                        )
                        
                        .listRowSeparator(.hidden)
                        .listRowSeparatorTint(Color.clear)
                        ArticleStubView()
                            .buttonStyle(PlainButtonStyle())
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 20)
                                .background(.clear)
                                .foregroundColor(Color("AdditionBackground"))
                                .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                        )
                        
                        .listRowSeparator(.hidden)
                        .listRowSeparatorTint(Color.clear)
                        Text("")
                            .frame(height: 50)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(-1..<self.ArticlesVM.articles.count, id: \.self) { articleIndex in
                        if articleIndex == -1 {
                            HStack {
                                Text("Today News")
                                    .robotoMono(.bold, 20, color: .primary)
                                Spacer()
                            }.listRowBackground(Color.clear)
                        }
                        else {
                            
                            let article: Article = self.ArticlesVM.articles[articleIndex]
                            // MARK: - Article post view
                            ArticlePostView(of: article, selected: self.$selectedArticle, tabBarObserver: self.$hideTabBar)
                                .buttonStyle(PlainButtonStyle())
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 20)
                                    .background(.clear)
                                    .foregroundColor(Color("AdditionBackground"))
                                    .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                            )
                            
                            .listRowSeparator(.hidden)
                            .listRowSeparatorTint(Color.clear)
                        }
                        
                    }
                        Text("")
                            .frame(height: 50)
                            .listRowBackground(Color.clear)
                    }
                    
                }
                .navigationBarHidden(true)
                .navigationBarTitle(Text("Home"))
                   
                .listStyle(PlainListStyle())
                    .onAppear {
                        UITableView.appearance().showsVerticalScrollIndicator = false
                        UITableView.appearance().separatorColor = UIColor.clear
                    }
                VStack(alignment: .center) {
                    LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: 5)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .publishOnTabBarAppearence(self.hideTabBar)
    }
}


