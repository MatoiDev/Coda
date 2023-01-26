//
//  SearchView.swift
//  Coda
//
//  Created by Matoi on 30.10.2022.
//

import SwiftUI

struct ExploreView: View {
    @State private var page: Int = 0
    var body: some View {
        TabView(selection: self.$page) {
            
            NewsViewMain().tag(0)
            TrendingView().tag(1)
            AnnouncementsView().tag(2)
            ProjectsView().tag(3)
            IdeasView().tag(4)
            VacationsView().tag(5)
            FreelanceView().tag(6)
            
        }.tabViewStyle(.page)
      
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
