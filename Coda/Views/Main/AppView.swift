//
//  AppView.swift
//  Coda
//
//  Created by Matoi on 30.10.2022.
//

import SwiftUI
import FirebaseFirestore

struct AppView: View {
    
    @ObservedObject private var fsmanager : FSManager = FSManager()
    @AppStorage("IsUserExists") var userExists : Bool = false
    @State var showView : Bool = false
    
    var body: some View {
        
        Group {
            if self.showView {
                if self.userExists {
                    // MARK: - TabBar
                    CodaTabBar()
                }
                else {
                    // MARK: - Data Editor
                    ZStack {
                        Image("WallpaperRegistration").edgesIgnoringSafeArea(.top)
                        DataEditor()
                    }
                }
            } else {
                // MARK: - View while user is determining
                ZStack {
                    Image("WallpaperRegistration").edgesIgnoringSafeArea(.top)
                    ProgressView()
                }
            }
        }.task {
            if !self.userExists {
                self.fsmanager.isUserExist()
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                    withAnimation {
                        self.showView = true
                    }
                }
            } else {
                withAnimation {
                    self.showView = true
                }
            }
        }
    }
}


struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
