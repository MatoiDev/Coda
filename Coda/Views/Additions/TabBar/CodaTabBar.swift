//
//  CodaTabBar.swift
//  Coda
//
//  Created by Matoi on 30.10.2022.
//

import SwiftUI

struct CodaTabBar: View {

    @State var selectedTab: Tab = .home
    @State var circleColor: Color = .cyan
    @AppStorage("UserID") private var userID : String = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .search:
                    SearchView()
                case .chat:
                    ChatView()
                case .profile:
                    // Вход в на свою страницу профиля по своему id
                    ProfileView(with: self.userID)
                }
            }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack {
                ForEach(tabItems) { item in
                    Button {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            selectedTab = item.tab
                            self.circleColor = item.color
                        }
                    } label: {
                        VStack {
                            Image(systemName: item.icon)
                                    .symbolVariant(selectedTab == item.tab ? .fill : .none)
                                    .font(.body.bold())
                                    .frame(width: 44, height: 29)
                            Text(item.footerText)
                                    .font(.caption2)
                                    .lineLimit(1)
                        }
                                .frame(maxWidth: .infinity)
                    }
                            .foregroundColor(selectedTab == item.tab ? .primary : .secondary)
                            .blendMode(selectedTab == item.tab ? .overlay : .normal)
                }
            }
                    .padding(.horizontal, 8)
                    .padding(.top, 16)
                    .frame(height: 88, alignment: .top)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 34, style: .continuous))
                    .background(
                        HStack {
                            if self.selectedTab == .profile { Spacer() }
                            if self.selectedTab == .chat { Spacer(); Spacer() }
                            if self.selectedTab == .search { Spacer() }
                            Circle().fill(self.circleColor).frame(width: 80)
                            if self.selectedTab == .chat { Spacer() }
                            if self.selectedTab == .search { Spacer(); Spacer() }
                            if self.selectedTab == .home { Spacer() }

                        }.padding(.horizontal, 8)

                    )
                    .overlay {
                        HStack {
                            if self.selectedTab == .profile { Spacer() }
                            if self.selectedTab == .chat { Spacer(); Spacer() }
                            if self.selectedTab == .search { Spacer() }
                            Rectangle()
                                    .fill(self.circleColor)
                                    .frame(width: 28, height: 5)
                                    .cornerRadius(3)
                                    .frame(width: 88)
                                    .frame(maxHeight: .infinity, alignment: .top)
                            if self.selectedTab == .chat { Spacer() }
                            if self.selectedTab == .search { Spacer(); Spacer() }
                            if self.selectedTab == .home { Spacer() }

                        }.padding(.horizontal, 8)
                        
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    
                    .ignoresSafeArea()
        }
    }
}

struct CodaTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CodaTabBar()
    }
}
