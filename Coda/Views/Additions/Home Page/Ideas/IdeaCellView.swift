//
//  IdeaCellView.swift
//  Coda
//
//  Created by Matoi on 01.04.2023.
//

import SwiftUI
import Kingfisher
import SwiftUIPager




struct IdeaCellView: View {
    
    @AppStorage("LoginUserID") var loginUserID: String = ""
    
    private let fsmanager: FSManager = FSManager()
    private let idea: Idea
    
    @State private var selectedIndex = 0
    
    @State private var authorUsername: String = ""
    @State private var avatar: String? = nil
    
    @StateObject private var page: Page = .first()
    
    @State private var comments: Array<String> = []
    @State private var views: Array<String> = []
    @State private var saves: Array<String> = []
    @State private var stars: Array<String> = []
    
    
    // -------------- Star Animation
    @State private var starYPositionOffset: CGFloat = 0
    @State private var starXPositionOffset: CGFloat = 0
    @State private var starRotationEffect: CGFloat = 0
    @State private var starYellowed: CGFloat = 0
    // --------------
    
    
    
    // -------------- Bookmark Animation
    @State private var bookmarkYPositionOffset: CGFloat = 0
    @State private var bookmarkXPositionOffset: CGFloat = 0
    @State private var bookmarkRotationEffect: CGFloat = 0
    @State private var bookmarkBlued: CGFloat = 0
    // --------------
    
    @State private var theIdeaWasStarredByTheLoginUser: Bool = false
    @State private var theIdeaWasSavedByTheLoginUser: Bool = false
    
    init (for idea: Idea) {
        
        self.idea = idea
        
        self.comments = self.idea.comments
        self.stars = self.idea.stars
        self.saves = self.idea.saves
        self.views = self.idea.views
        
        self.theIdeaWasSavedByTheLoginUser =  self.idea.saves.contains(self.loginUserID)
        self.theIdeaWasStarredByTheLoginUser = self.idea.comments.contains(self.loginUserID)
        
    }
    
    
    
    
    var body: some View {
        VStack {
            // MARK: - UserInfo
            
            if self.idea.images.count == 1 {
                CachedImageView(with: idea.images[0], for: .Default)
                    .frame(width: UIScreen.main.bounds.width, height: 200)
                    .aspectRatio(contentMode: .fill)
            } else if self.idea.images.count > 1 {
                
                Pager(page: self.page, data: self.idea.images, id: \.self) { image in
                    CachedImageView(with: image, for: .Default)
                    
                        .frame(width: UIScreen.main.bounds.width, height: 200)
                }
                .loopPages()
                .interactive(scale: 0.8)
                .frame(height: 200)
        
            }
            HStack {
                CachedImageView(with: self.avatar, for: .Default)
                    .frame(width: 50, height: 50, alignment: .center)
                    .cornerRadius(5)
                    .padding(.leading)
                    .padding(.trailing, 6)
                    .padding(.top, 6)
                VStack(alignment: .leading) {
                    Text("User")
                        .robotoMono(.medium, 15, color: .secondary)
                    Text(self.authorUsername)
                        .robotoMono(.bold, 16, color: .primary)
                }
                Spacer()
            }
            // MARK: - Title
            HStack {
                Text(idea.title)
                    .padding(.horizontal)
                Spacer()
            }.robotoMono(.medium, 15)
            
       
            HStack {
                // MARK: - Stars & Views
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "star\(self.theIdeaWasStarredByTheLoginUser ? ".fill" : "")")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundColor(Color(red: 0.57 + 0.35 * self.starYellowed, green: 0.58 + self.starYellowed * 0.03, blue: 0.58 - 0.58 * self.starYellowed))
                            .font(.system(size: 15, weight: .black, design: .rounded))
                        Text("\(self.stars.count) ") + Text("stars")
                    }
                    HStack {
                        Image("eye")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundColor(.secondary)
                            .font(.system(size: 15, weight: .black, design: .rounded))
                        Text("\(self.views.count) ") + Text("views")
                    }
                }
                .padding(.trailing)
                .robotoMono(.medium, 15, color: Color(red: 0.57, green: 0.58, blue: 0.63))
                
                
                // MARK: - Views And Comments
                VStack(alignment: .leading) {
                    
                    HStack {
                        Image(systemName: "bookmark\(self.bookmarkBlued == 1 ? ".fill" : "")")
                                .resizable()
                                .frame(width: 12, height: 16)
                                .foregroundColor(Color(red: 0.57 - 0.04 * self.bookmarkBlued, green: 0.58 + self.bookmarkBlued * 0.09, blue: 0.58 + 0.34 * self.bookmarkBlued))
                                .font(.system(size: 15, weight: .black, design: .rounded))
                        Text("\(self.saves.count) ") + Text("saves")
                    }
                    HStack {
                        Image(systemName: "bubble.left")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundColor(.secondary)
                            .font(.system(size: 15, weight: .black, design: .rounded))
                        Text("\(self.comments.count) ") + Text("comments")
                    }
                  
                }.robotoMono(.medium, 15, color: Color(red: 0.57, green: 0.58, blue: 0.63))
                Spacer()
            }
            .padding(.horizontal)
            .robotoMono(.medium, 15, color: Color(red: 0.57, green: 0.58, blue: 0.63))
            

            
            if self.idea.images.count > 0 {
                Spacer()
            }
            
            // MARK: - Star Button
            HStack {
                Button {
                    print("Star Idea: \(self.theIdeaWasStarredByTheLoginUser)")
                    withAnimation {
                        if self.theIdeaWasStarredByTheLoginUser {
                       
                            withAnimation(Animation.spring()) {
                                self.starRotationEffect = -360
                                self.starYPositionOffset = -100
                                self.starYellowed = 0.5
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)){
                                withAnimation(Animation.spring()) {
                                    self.starYPositionOffset = 0
                                    self.starYellowed = 0
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)){
                                    self.fsmanager.unlike(idea: self.idea.id, user: self.loginUserID, owner: self.idea.author)
                                }
                            }
                        } else {
                            
                            withAnimation(Animation.spring()) {
                                self.starYPositionOffset = -20
                                self.starRotationEffect = -360
                                self.starYellowed = 0.5
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)){
                                withAnimation(Animation.spring()) {
                                    self.starYPositionOffset = 0
                                    self.starRotationEffect = 0
                                    self.starYellowed = 1
                                    
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)){
                                    self.fsmanager.like(idea: self.idea.id, user: self.loginUserID, owner: self.idea.author)
                                }
             
                            }
                        }
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                        
                            .foregroundColor(Color(red: 0.21 + 0.71 * self.starYellowed, green: 0.23 + self.starYellowed * 0.38, blue: 0.26 - 0.26 * self.starYellowed))
                            
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.secondary, lineWidth: 0.2)
                            }
                        HStack {
                            Image(systemName: "star")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .foregroundColor(Color(red: 0.76 - 0.76 * self.starYellowed, green: 0.76 - 0.76 * self.starYellowed, blue: 0.79 - 0.79 * self.starYellowed))
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .offset(x: self.starXPositionOffset, y: self.starYPositionOffset)
                                .rotationEffect(Angle(degrees: self.starRotationEffect))
                            if self.starYellowed == 0 {
                                Text("Star")
                                    .foregroundColor(Color(red: 0.76 - 0.76 * self.starYellowed, green: 0.76 - 0.76 * self.starYellowed, blue: 0.79 - 0.79 * self.starYellowed))
                            }
                   
                        }.robotoMono(.medium, 15, color: Color(red: 0.76, green: 0.76, blue: 0.79))
                   
                    }   .frame(height: 45)
                        .frame(width: UIScreen.main.bounds.width - 32 - (UIScreen.main.bounds.width - 32 - 45) * self.starYellowed)
                   
                }
                .padding(self.starYellowed == 0 ? .horizontal : .leading)
                
                // MARK: - Save button
                if self.starYellowed == 1 {
                    Button {
                        print("add this idea to bookmarks")
                        
                        withAnimation {
                            if self.theIdeaWasSavedByTheLoginUser {
                                
                                withAnimation(Animation.spring()) {
                                    self.bookmarkBlued = 0.5
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)){
                                    withAnimation(Animation.spring()) {
                                        self.bookmarkBlued = 0
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)){
                                        self.fsmanager.removeFromFavs(idea: self.idea.id, user: self.loginUserID, owner: self.idea.author)
                                    }
                                }
                            } else {
                                withAnimation(Animation.spring()) {
                                    self.bookmarkBlued = 0.5
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)){
                                    withAnimation(Animation.spring()) {
                                        self.bookmarkBlued = 1
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)){
                                        self.fsmanager.save(idea: self.idea.id, user: self.loginUserID, owner: self.idea.author)
                                    }
                                }
                            }
                            
                        }
                        
                        
                        
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
//                            rgb(53%, 67%, 92%, 1);
                                .foregroundColor(Color(red: 0.21 + 0.32 * self.bookmarkBlued, green: 0.23 + 0.44 * self.bookmarkBlued, blue: 0.26 + 0.66 * self.bookmarkBlued))
                                
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.secondary, lineWidth: 0.2)
                                }
                            HStack {
                                Image("bookmark")
                                    .resizable()
                                    .frame(width: 18, height: 20)
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                    .foregroundColor(Color(red: 0.76 - 0.76 * self.bookmarkBlued, green: 0.76 - 0.76 * self.bookmarkBlued, blue: 0.79 - 0.79 * self.bookmarkBlued))
                                Text("Save to favorites")
//                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                    .robotoMono(.bold, 15, color: Color(red: 0.76 - 0.76 * self.bookmarkBlued, green: 0.76 - 0.76 * self.bookmarkBlued, blue: 0.79 - 0.79 * self.bookmarkBlued))
                                    
                            }
                        }.frame(maxWidth: .infinity)
                            .frame(height: 45)
                    }
                    .padding(.trailing)
                }
             
                    
            }
            .padding(.top, 6)
                .padding(.bottom)

 
            
            
        }
        .onAppear {
            print(self.idea.stars, self.loginUserID, "__")
          
            self.theIdeaWasStarredByTheLoginUser = self.idea.stars.contains(self.loginUserID)
            self.starYellowed = self.idea.stars.contains(self.loginUserID) ? 1 : 0
            
            self.theIdeaWasSavedByTheLoginUser = self.idea.saves.contains(self.loginUserID)
            self.bookmarkBlued = self.idea.saves.contains(self.loginUserID) ? 1 : 0
        }
        .task {
            self.fsmanager.getIdeaInfo(id: self.idea.id) { result in
                switch result {
                case .success(let statisticsData):
                    if let comments = statisticsData["comments"] as? Array<String>,
                       let views = statisticsData["views"] as? Array<String>,
                       let stars = statisticsData["stars"] as? Array<String>,
                       let saves = statisticsData["saves"] as? Array<String> {
                        
                        self.stars = stars
                        self.comments = comments
                        self.views = views
                        self.saves = saves
                        
                        self.theIdeaWasSavedByTheLoginUser = saves.contains(self.loginUserID)
                        self.theIdeaWasStarredByTheLoginUser = stars.contains(self.loginUserID)
                        self.starYellowed = stars.contains(self.loginUserID) ? 1 : 0
                        self.bookmarkBlued = saves.contains(self.loginUserID) ? 1 : 0
                    }
                case .failure(let failure):
                    print("IdeaCellView:  cannot load IdeasListener \(failure.localizedDescription)")
                }
            
            }
            self.fsmanager.getUserAvatar(withID: self.idea.author) { result in
                switch result {
                case .success(let avatar):
                    self.avatar = avatar
                case .failure(let failure):
                    print("IdeaCellView: Error with fetching author avatar: \(failure.localizedDescription)")
                }
            }
            
            await self.fsmanager.getUserName(forID: self.idea.author, completion: { result in
                switch result {
                case .success(let username):
                    self.authorUsername = username
                case .failure(let failure):
                    print("IdeaCellView: Error with fetching author username: \(failure.localizedDescription)")
                }
            })
        }
        
       
    }
}

struct IdeaCellView_Previews: PreviewProvider {
    static var previews: some View {
        IdeaCellView(for: Idea(id: "123", author: "Matoi", title: "Write a simple Siri customizer", text: "The Idea's Body", category: "Development", subcategory: "iOS", difficultyLevel: "Lead", skills: "Xcode, AppCode, Logos, iOS", languages: ["Objective-C", "Logos", "Swift"], images: [], files: [], time: 12.123, comments: [], stars: [], responses: [], views: [], saves: [], dateOfPublish: "1 Apr at 13:49"))
    }
}
