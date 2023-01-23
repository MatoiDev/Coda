//
//  Model.swift
//  Coda
//
//  Created by Matoi on 20.12.2022.
//

import SwiftUI

@MainActor class AppConfiguration: ObservableObject {
    
    @Published var tabBarIsHidden: Bool = false
    
    func hideTabBar() -> Void {
        self.tabBarIsHidden = true
    }
    
    func showTabBar() -> Void {
        self.tabBarIsHidden = false
    }
    
    func reloadView() {
        objectWillChange.send()
    }
}


struct TabBarAppearencePreference: PreferenceKey {
    static var defaultValue: Bool = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}


extension View {
    func publishOnTabBarAppearence(_ value: Bool) -> some View {
        preference(key: TabBarAppearencePreference.self, value: value)
    }
}
