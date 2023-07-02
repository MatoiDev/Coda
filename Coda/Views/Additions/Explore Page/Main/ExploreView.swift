//
//  SearchView.swift
//  Coda
//
//  Created by Matoi on 30.10.2022.
//

import SwiftUI
import Pages
import PagerTabStripView

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
                TrendsView().tag(1)
//                ProjectsView().tag(2)
                IdeasView().tag(3)
                JobView().tag(4)
            }
        }
    
        
//        PagerTabStripView {
//            NewsViewMain()
//                .pagerTabItem { EmptyView() }.tag(0)
//
//            TrendsView().pagerTabItem { EmptyView() }.tag(1)
//            AnnouncementsView().pagerTabItem { EmptyView() }.tag(2)
//            ProjectsView().pagerTabItem { EmptyView() }.tag(3)
//            IdeasView().pagerTabItem { EmptyView() }.tag(4)
//            VacancyView().pagerTabItem { EmptyView() }.tag(5)
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
//            TrendsView().tag(1)
//            AnnouncementsView().tag(2)
//            ProjectsView().tag(3)
//            IdeasView().tag(4)
//            VacancyView().tag(5)
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
