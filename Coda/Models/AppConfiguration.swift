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
