//
//  TabItem.swift
//  Coda
//
//  Created by Matoi on 30.10.2022.
//


import Foundation
import SwiftUI


class TabItem: Identifiable {

    var id: UUID = UUID()
    @State var isPressed: Bool = false
    var tab: Tab
    var footerText: String
    var icon: String
    var color: Color

    init(withTab tab: Tab, icon: String, text: String, color: Color) {
        self.tab = tab
        self.icon = icon
        self.footerText = text
        self.color = color
    }

}


var tabItems: Array<TabItem> = [
    TabItem.init(withTab: .home, icon: "house", text: "Home", color: .cyan),
    TabItem.init(withTab: .search, icon: "magnifyingglass", text: "Search", color: .pink),
    TabItem.init(withTab: .chat, icon: "message", text: "Chat", color: .green),
    TabItem.init(withTab: .profile, icon: "person", text: "Profile", color: .purple)
]