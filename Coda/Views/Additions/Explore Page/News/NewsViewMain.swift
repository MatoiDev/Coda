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
    
    @State private var selectedArticle: Article = Article.SOLID
    
    var body: some View {
        NavigationView {
            List {
                ForEach(-1..<self.ArticlesVM.articles.count, id: \.self) { articleIndex in
                    if articleIndex == -1 {
                        HStack {
                            Text("Today News").font(.custom("RobotoMono-Bold", size: 20)).foregroundColor(.primary)
                            Spacer()
                        }.listRowBackground(Color.clear)
                    }
                    else {
                        let article: Article = self.ArticlesVM.articles[articleIndex]
                        // MARK: - Article post view
                        ArticlePostView(of: article, selected: self.$selectedArticle, tabBarObserver: self.$hideTabBar)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 20)
                                .background(.clear)
                                .foregroundColor(Color("AdditionBackground"))
                                .padding(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
                        )
                        .listRowSeparator(.hidden)
                        .listRowSeparatorTint(Color.clear)
                    }
                    
                }
                
            }
            .navigationBarHidden(true)
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
