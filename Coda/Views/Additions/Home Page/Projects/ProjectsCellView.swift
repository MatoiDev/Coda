//
//  ProjectsCellView.swift
//  Coda
//
//  Created by Matoi on 28.05.2023.
//

import SwiftUI
import Kingfisher
import SwiftUIPager

struct ProjectsCellView: View {

        
        @AppStorage("LoginUserID") var loginUserID: String = ""
        
        private let fsmanager: FSManager = FSManager()
        private let project: Project
        
        @State private var selectedIndex = 0
        
        @State private var authorUsername: String = ""
        @State private var avatar: String? = nil
        
        @StateObject private var page: Page = .first()
        
        @State private var comments: Array<String> = []
        @State private var commentsCount: Int = 0
        @State private var views: Array<String> = []
        @State private var saves: Array<String> = []
        @State private var upvotes: Array<String> = []
        
        
        
        // --------------- Star Animation
        @State private var starYPositionOffset: CGFloat = 0
        @State private var starXPositionOffset: CGFloat = 0
        @State private var starRotationEffect: CGFloat = 0
        @State private var starYellowed: CGFloat = 0
        // ---------------
        
        
        
        // --------------- Bookmark Animation
        @State private var bookmarkYPositionOffset: CGFloat = 0
        @State private var bookmarkXPositionOffset: CGFloat = 0
        @State private var bookmarkRotationEffect: CGFloat = 0
        @State private var bookmarkBlued: CGFloat = 0
        // ---------------
        
        @State private var theProjectWasStarredByTheLoginUser: Bool = false
        @State private var theProjectWasSavedByTheLoginUser: Bool = false
        
        init (for project: Project) {
            
            self.project = project
            
            self.comments = self.project.comments
            self.upvotes = self.project.upvotes
            self.saves = self.project.saves
            self.views = self.project.views
            
            self.theProjectWasSavedByTheLoginUser =  self.project.saves.contains(self.loginUserID)
            self.theProjectWasStarredByTheLoginUser = self.project.comments.contains(self.loginUserID)
            
        }
    
    var body: some View {
        Text("")
    }
}

struct ProjectsCellView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsCellView(for: Project(id: "id", author: "author", title: "Violet", description: "A maid for your iPhone", category: "Development", subtopic: "iOS", projectDetails: "AppCode, Logos, Reverse Engieniering", langdescriptors: ["Objective-C, Swift, C, C++"], previews: [], files: [], time: 12341235.902341, comments: [], commentsCount: 0, upvotes: [], downvotes: [], linkToTheSource: "https://github.com/MatoiDev/Violet", views: [], saves: [], date: "23 Dec 2022"))
    }
}
