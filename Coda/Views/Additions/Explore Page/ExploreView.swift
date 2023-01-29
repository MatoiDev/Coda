//
//  SearchView.swift
//  Coda
//
//  Created by Matoi on 30.10.2022.
//

import SwiftUI
import Pages
import PagerTabStripView

struct ExploreHeaderViewCell: View {
    
    let title: String
    let image: String?
    let selected: Bool
    
    var body: some View {
        HStack {
            Text(self.title)
                .padding(.leading, 4)
                .padding(.vertical, 2)
                
            if let imageName: String = self.image {
                if imageName == "lightbulb", selected {
                    Image(systemName: "lightbulb.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 15)
                        .padding(.trailing, 4)
                } else {
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 15)
                        .padding(.trailing, 4)
                }
                
                    
            }
        }
        .foregroundColor(.white)
        .font(.custom("RobotoMono-SemiBold", size: 15))
        .padding(4)
        .background(
            self.selected ? LinearGradient(colors: [Color("Register2").opacity(0.45), .cyan.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                LinearGradient(colors: [Color("AdditionDarkBackground")], startPoint: .leading, endPoint: .trailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(LinearGradient(colors: [Color("Register2"), .cyan], startPoint: .topLeading, endPoint: .bottom), style: .init(lineWidth: 1))
        }
        .frame(height: 35)
       
    }
}

struct ExploreHeaderView: View {
    @Binding var selectedPage: Int
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ZStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        
                        Button {
                            self.selectedPage = 0
                        } label: { ExploreHeaderViewCell(title: "News", image: "newspaper", selected: self.selectedPage == 0).id(0) }
                        
                        Button {
                            
                            self.selectedPage = 1
                        } label: { ExploreHeaderViewCell(title: "Trending", image: "flame", selected: self.selectedPage == 1).id(1) }
                        
                        Button {
                            
                            self.selectedPage = 2
                        } label: { ExploreHeaderViewCell(title: "Projects", image: "shippingbox", selected: self.selectedPage == 2).id(2) }
                        
                        Button {
                            
                            self.selectedPage = 3
                        } label: { ExploreHeaderViewCell(title: "Announcement", image: "exclamationmark.circle", selected: self.selectedPage == 3).id(3) }
                        
                        Button {
                            
                            self.selectedPage = 4
                            
                        } label: { ExploreHeaderViewCell(title: "Ideas", image: "lightbulb", selected: self.selectedPage == 4).id(4) }
                        
                        Button {
                            
                            self.selectedPage = 5
                            
                        } label: { ExploreHeaderViewCell(title: "Vacations", image: "person.text.rectangle", selected: self.selectedPage == 5).id(5) }
                        
                        // 6) Найм на работу,
                        
                        // 7) Поиск команды на работу
                        
                        
                        Button {
                            withAnimation(.easeInOut) {
                                scrollProxy.scrollTo(6)
                            }
                            self.selectedPage = 6
                            
                        } label: { ExploreHeaderViewCell(title: "Freelance", image: "creditcard", selected: self.selectedPage == 6).id(6) }
                        
                    }.padding(.horizontal)
                }
                HStack {
                    LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                        .frame(maxHeight: .infinity)
                        .frame(width: 10)
                    Spacer()
                    LinearGradient(colors: [.clear, .black], startPoint: .leading, endPoint: .trailing)
                        .frame(maxHeight: .infinity)
                        .frame(width: 10)
                }
            }
            .onChange(of: self.selectedPage, perform: { [previousPage = self.selectedPage] selection in
                print(selection, previousPage)
                switch selection {
                case 0: withAnimation(.easeInOut) { scrollProxy.scrollTo(0) }
                case 1: withAnimation(.easeInOut) { scrollProxy.scrollTo(previousPage > 1 ? 0 : 1) }
                case 2: withAnimation(.easeInOut) { scrollProxy.scrollTo(previousPage > 2 ? 0 : 3) }
                case 3: withAnimation(.easeInOut) { scrollProxy.scrollTo(previousPage > 3 ? 2 : 4) }
                case 4: withAnimation(.easeInOut) { scrollProxy.scrollTo(previousPage > 3 ? 3 : 5) }
                case 5: withAnimation(.easeInOut) { scrollProxy.scrollTo(6) }
                default: withAnimation(.easeInOut) { scrollProxy.scrollTo(6) }
                }
            })

        }
       
        .frame(height: 35)
        .frame(maxWidth: .infinity)
    }
}

struct ExploreView: View {
    
    @State private var page: Int = 0
   
    @AppStorage("hideTabBar") var ASHideTabBar: Bool = false
    
    var body: some View {
        VStack {
            if !self.ASHideTabBar {
                ExploreHeaderView(selectedPage: self.$page)
            } else { EmptyView() }

            Pages(currentPage: self.$page) {
                NewsViewMain().tag(0)
                TrendingView().tag(1)
                ProjectsView().tag(2)
                AnnouncementsView().tag(3)
                IdeasView().tag(4)
                VacationsView().tag(5)
                FreelanceView().tag(6)
            }
        }
    
        
//        PagerTabStripView {
//            NewsViewMain()
//                .pagerTabItem { EmptyView() }.tag(0)
//
//            TrendingView().pagerTabItem { EmptyView() }.tag(1)
//            AnnouncementsView().pagerTabItem { EmptyView() }.tag(2)
//            ProjectsView().pagerTabItem { EmptyView() }.tag(3)
//            IdeasView().pagerTabItem { EmptyView() }.tag(4)
//            VacationsView().pagerTabItem { EmptyView() }.tag(5)
//            FreelanceView().pagerTabItem { EmptyView() }.tag(6)
//
//        }
//        .pagerTabStripViewStyle(.barButton(indicatorBarHeight: 0, indicatorBarColor: Color("Register2"), tabItemSpacing: 20,
//                                                  tabItemHeight: 15,
//                                                  placedInToolbar: true))
//        .ignoresSafeArea()
//        .publishOnTabBarAppearence(self.hideTabBar)
//
//        TabView(selection: self.$page) {
//
//            NewsViewMain().tag(0)
//            TrendingView().tag(1)
//            AnnouncementsView().tag(2)
//            ProjectsView().tag(3)
//            IdeasView().tag(4)
//            VacationsView().tag(5)
//            FreelanceView().tag(6)
//
//        }
//        .unredacted()
//        .tabViewStyle(.page(indexDisplayMode: .never))
//        .publishOnTabBarAppearence(true)
      
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
