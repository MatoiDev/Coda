//
//  ExploreViewHeader.swift
//  Coda
//
//  Created by Matoi on 31.01.2023.
//

import SwiftUI

struct ExploreHeaderView: View {
    
    @Binding var selectedPage: Int
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ZStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        EmptyView().frame(width: 0, height: 0).id(-1)
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
                        } label: { ExploreHeaderViewCell(title: "Ideas", image: "lightbulb", selected: self.selectedPage == 3).id(3) }
                        
                        Button {
                            
                            self.selectedPage = 4
                            
                        } label: { ExploreHeaderViewCell(title: "Job", image: "creditcard", selected: self.selectedPage == 4).id(4) }
                                                
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
                case 0: withAnimation(.easeInOut) { scrollProxy.scrollTo(-1, anchor: .trailing) }
                case 1: withAnimation(.easeInOut) { scrollProxy.scrollTo(previousPage > 1 ? -1 : 1, anchor: .trailing) }
                case 2: withAnimation(.easeInOut) { scrollProxy.scrollTo(previousPage > 2 ? -1 : 3, anchor: .leading) }
                case 3: withAnimation(.easeInOut) { scrollProxy.scrollTo(previousPage > 3 ? 2 : 4, anchor: .leading) }
                case 4: withAnimation(.easeInOut) { scrollProxy.scrollTo(previousPage > 3 ? 3 : 5, anchor: .leading) }
                case 5: withAnimation(.easeInOut) { scrollProxy.scrollTo(6, anchor: .leading) }
                default: withAnimation(.easeInOut) { scrollProxy.scrollTo(6, anchor: .leading) }
                }
            })

        }
       
        .frame(height: 35)
        .frame(maxWidth: .infinity)
    }
}
