//
//  IdeaContentView.swift
//  Coda
//
//  Created by Matoi on 06.04.2023.
//



import SwiftUI
import Foundation
import Combine
import SwiftUIPager
import Introspect




// TODO: Настроить отображение уровня сложности, а так же рейтинга идеи.

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

enum BottomSheetPositionPost: CGFloat, CaseIterable {
    case bottom = 60
    case middle = 400
}

struct IdeaContentView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @AppStorage("LoginUserID") var loginUserID: String = ""
    private let fsmanager: FSManager = FSManager()
    
    @State private var showAuthorProfileView: Bool = false
    @State private var controlOpacity: CGFloat = 1
    @State var textFieldHeight: CGFloat = 30
    private let idea: Idea
    
    @State private var comments: Array<String> = []
    @State private var views: Array<String> = []
    @State private var saves: Array<String> = []
    @State private var stars: Array<String> = []
    
    // Используется для того, чтобы отображать отправку сообщения при его подгрузке или скрывать view комментария после его отправки
    @State private var messageEditingHandler: MessageState = .editing
    
    @Binding var hideTabBar: Bool
    
    @State var position: BottomSheetPosition = .relativeBottom(0.125)
    
    @State private var commentMessage: String = ""
    @State private var commentsTextFieldIsFirstResponder: Bool = false
    
    @State private var forceTopPosition: Bool = false
    
    @State private var modelComments: Array<Comment> = []

    
    
    init(withIdea idea: Idea, hideTabBar: Binding<Bool>) {
        
        self.idea = idea
        self._hideTabBar = hideTabBar
        
 
        self.comments = self.idea.comments
        self.stars = self.idea.stars
        self.saves = self.idea.saves
        self.views = self.idea.views
       
        
        self.theIdeaWasSavedByTheLoginUser =  self.idea.saves.contains(self.loginUserID)
        self.theIdeaWasStarredByTheLoginUser = self.idea.comments.contains(self.loginUserID)
        
        
    }
    @State private var showCommentController: Bool = false
    
    @State private var starYellowed: CGFloat = 0
    @State private var bookmarkBlued: CGFloat = 0
    
    @State private var theIdeaWasStarredByTheLoginUser: Bool = false
    @State private var theIdeaWasSavedByTheLoginUser: Bool = false
    
    @StateObject private var page: Page = .first()
    
    @ObservedObject var timer: CombineTimer = CombineTimer(2)
    
    @State var bottomSheetPosition: BottomSheetPositionPost = .bottom
    
    @State var starScaledEffect: CGFloat = 1
    @State var bookmarkScaledEffect: CGFloat = 1
    
    
    var body: some View {
        ZStack {
            Color("AdditionDarkBackground").ignoresSafeArea()
            
            ScrollView {
                // MARK: - Post
                VStack(alignment: .leading) {
                    
                    // MARK: - Business card
                    Button {
                        self.showAuthorProfileView.toggle()
                    } label: {
//                        BusinessCardAsync(withType: .author, userID: self.idea.author)
                        IdeaHeaderView(with: self.idea.author, time: self.idea.dateOfPublish)
                            .padding(.horizontal)
                            .padding(.top)
                    }


                    
                    // MARK: - Title
                    
                    HStack {
                        Text(idea.title)
                            .robotoMono(.bold, 25)
                            .lineLimit(2)
                            .minimumScaleFactor(0.2)
                        Spacer()
                    }
                    .padding(.top, 4)
                    .padding(.horizontal, 24)
                    
                    
                    // MARK: - Tags
                    
                    WrappingHStack(tags: self.idea.languages + self.getTags(from: self.idea.skills))
                        .padding(.horizontal)
                        .padding(.top, -8)
                    
                
//                    BusinessCard(type: .author, image: self.$imageLoader.image, error: self.$imageLoader.errorLog, firstName: self.userFirstName, lastName: self.userLastName, reputation: self.userReputation)
//                        .padding()
                    // MARK: - Date, comments & views
//                    HStack(alignment: .center) {
//                        Text(self.idea.dateOfPublish)
//                            .padding(.leading, 24)
//                            .robotoMono(.light, 12, color: Color(red: 0.80, green: 0.80, blue: 0.80))
//
//                        Spacer()
//                        HStack {
//                            Text("\(self.idea.comments.count)")
//                                .foregroundColor(.white)
//                                .robotoMono(.medium, 14)
//                            Image("chat")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 15, height: 15)
//                                .robotoMono(.light, 12, color: Color(red: 0.80, green: 0.80, blue: 0.80))
////                                .padding(.trailing)
//                            Divider()
//                            Text("\(self.idea.views.count)")
//                                .foregroundColor(.white)
//                                .robotoMono(.medium, 14)
//                            Image(systemName: "eye")
//                                .robotoMono(.light, 12, color: Color(red: 0.80, green: 0.80, blue: 0.80))
//                        }
//
//                        .padding(2)
//                        .padding(.horizontal, 4)
//                        .background(Color("BubbleMessageRecievedColor"), in: RoundedRectangle(cornerRadius: 30))
//                        .overlay {
//                            RoundedRectangle(cornerRadius: 30)
//                                .stroke(Color(red: 0.80, green: 0.80, blue: 0.80), lineWidth: 1)
//                        }
//                        .padding(.trailing)
//                        .padding(4)
//                        .fixedSize()
//
//
//                    }.padding(.top, -8)
                    
                    // MARK: - Previews
                    if !self.idea.images.isEmpty {
                        if self.idea.images.count == 1 {
                            CachedImageView(with: idea.images[0], for: .Default)
                                .frame(width: UIScreen.main.bounds.width, height: 200)
                                .aspectRatio(contentMode: .fill)
                                .padding(.top, 4)
                        } else if self.idea.images.count > 1 {
                            
                            ZStack(alignment: .bottom) {
                                Pager(page: self.page, data: self.idea.images, id: \.self) { image in
                                    CachedImageView(with: image, for: .Default)
                                        
                                        .frame(width: UIScreen.main.bounds.width, height: 200)
                                        .padding(.top, 4)
                                }.loopPages()
                                    .interactive(scale: 0.8)
                                ZStack {
                                   
                                    PageControl(currentPageIndex: self.page.index, numberOfPages: self.idea.images.count)
                                        
                                        .frame(width: CGFloat(self.idea.images.count * 30) - 20, height: 20)
                                        .background(Color.secondary)
                                        .backgroundBlur()
                                        .clipShape(RoundedRectangle(cornerRadius: 100))
                                        .padding(.bottom, 4)
                                        .opacity(self.controlOpacity)
                                        .onAppear {
                                            self.timer.startTimer {
                                                withAnimation {
                                                    self.controlOpacity = 0
                                                }
                                            }
                                        }
                                        
                                        
                                        
                                }
                             
                            }
                            
                            .frame(height: 200)
                    
                        }
                    }
                    
                    
                    // MARK: - Files
//                    if let files = self.idea.files, !self.idea.files.isEmpty {
//
//                        VStack {
//                            HStack {
//                                Text("Files")
//                                    .robotoMono(.semibold, 18, color: .secondary)
//                                    Spacer()
//                            }.padding(.horizontal, 8)
//                                .padding(.bottom, 4)
//                                .padding(.horizontal)
//                            HStack(alignment: .center, spacing: 8) {
//                                Spacer()
//                                    ForEach(files, id: \.self) { url in
//
//                                        if let file_Attr = url.fileAttributes {
//                                            VStack(alignment: .center) {
//
//                                                Image(systemName: "doc.viewfinder")
//                                                        .resizable()
//                                                        .frame(width: 45, height: 45)
//                                                        .symbolRenderingMode(.hierarchical)
//                                                        .foregroundColor(.primary)
//                                                        .padding(.top)
//                                                Spacer()
//                                                Text(file_Attr.name)
//                                                    .lineLimit(1)
//                                                    .padding(.horizontal)
//                                                    .robotoMono(.semibold, 13)
//
//                                                Text(Double(file_Attr.size).bytesToHumanReadFormat())
//                                                    .lineLimit(1)
//                                                    .padding(.horizontal)
//                                                    .robotoMono(.semibold, 10, color: .secondary)
//                                                    .padding(.bottom)
//
//                                            }
//                                            .frame(
//                                                width: UIScreen.main.bounds.width / 3.5,
//                                                height: UIScreen.main.bounds.width / 3.5
//                                            )
//                                            .clipShape(RoundedRectangle(cornerRadius: 20))
//                                            .overlay {
//                                                RoundedRectangle(cornerRadius: 20)
//                                                    .stroke(Color.secondary, lineWidth: 4)
//                                            }
//                                        }
//
//
//                                }
//                                Spacer()
//                            }.padding(.horizontal)
//                        }
//                    }
                    
                
                    // MARK: - Text
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Idea Description")
                                .robotoMono(.semibold, 18, color: .secondary)
                                Spacer()
                        }.padding(.horizontal, 8)
                            .padding(.bottom, 4)
                     
                        Text(LocalizedStringKey(self.idea.text))
                    }
                    .padding(.horizontal)
                    
                    // TODO: - Here must be comments
                    // MARK: - Idea's info
//                    Divider()
                    HStack {
            
                            // MARK: - Stars
                            HStack {
                                Button {
                                    withAnimation {
                                        if self.theIdeaWasStarredByTheLoginUser {
                                       
                                            withAnimation(Animation.spring()) {
                                                self.starYellowed = 0.5
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)){
                                                withAnimation(Animation.spring()) {
                                                    self.starYellowed = 0
                                                }
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)){
                                                    self.fsmanager.unlike(idea: self.idea.id, user: self.loginUserID, owner: self.idea.author)
                                                }
                                            }
                                        } else {
                                            
                                            withAnimation(Animation.spring()) {
                                                self.starYellowed = 0.5
                                                self.starScaledEffect = 2.5
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)){
                                                withAnimation(Animation.spring()) {
                                                    self.starYellowed = 1
                                                    self.starScaledEffect = 1
                                                    
                                                }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)){
                                                    self.fsmanager.like(idea: self.idea.id, user: self.loginUserID, owner: self.idea.author)
                                                }
                             
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "star\(self.theIdeaWasStarredByTheLoginUser ? ".fill" : "")")
                                            .resizable()
                                            .scaleEffect(self.starScaledEffect)
                                            .frame(width: 18, height: 18)
                                            .foregroundColor(Color(red: 0.57 + 0.35 * self.starYellowed, green: 0.58 + self.starYellowed * 0.03, blue: 0.58 - 0.58 * self.starYellowed))
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        Text("\(self.stars.count)")
                                          
                                    
                                    }.padding(2)
                                        .padding(.horizontal, 8)
                                        .background(Color(red: 0.137 + 0.79 * self.starYellowed, green: 0.137 + 0.79 * self.starYellowed, blue: 0.145 - 0.145 * self.starYellowed).opacity(1.0 - 0.8 * self.starYellowed))
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                                    
                                }
                              
                            }
                        Spacer()
                        // MARK: - Comments
                            HStack {
                                Image(systemName: "bubble.left")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                Text("\(self.comments.count)")
                            }.padding(2)
                            .padding(.horizontal, 8)
                            .background(Color(red: 0.137, green: 0.137, blue: 0.145))
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                        // MARK: - Saves
                        Spacer()
                            HStack {
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
                                                self.bookmarkScaledEffect = 2.5
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)){
                                                withAnimation(Animation.spring()) {
                                                    self.bookmarkBlued = 1
                                                    self.bookmarkScaledEffect = 1
                                                }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)){
                                                    self.fsmanager.save(idea: self.idea.id, user: self.loginUserID, owner: self.idea.author)
                                                }
                                            }
                                        }
                                        
                                    }
                                    
                                    
                                    
                                } label: {
                                    HStack {
                                        Image(systemName: "bookmark\(self.bookmarkBlued == 1 ? ".fill" : "")")
                                                .resizable()
                                                .scaleEffect(self.bookmarkScaledEffect)
                                                .frame(width: 14, height: 17)
                                                .foregroundColor(Color(red: 0.57 - 0.04 * self.bookmarkBlued, green: 0.58 + self.bookmarkBlued * 0.09, blue: 0.58 + 0.34 * self.bookmarkBlued))
                                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        Text("\(self.saves.count)")
                                    }.padding(2)
                                        .padding(.horizontal, 8)
                                        .background(Color(red: 0.137 + 0.4 * self.bookmarkBlued, green: 0.137 + 0.54 * self.bookmarkBlued, blue: 0.145 + 0.78 * self.bookmarkBlued).opacity(1.0 - 0.8 * self.bookmarkBlued))
                                    .clipShape(RoundedRectangle(cornerRadius: 25))
                                }
                           
                            }
                        // MARK: - Views
                        Spacer()
                            HStack {
                                Image(systemName: "eye")
                                    .resizable()
                                    .frame(width: 23, height: 17)
                                    .foregroundColor(Color(red: 0.57, green: 0.58, blue: 0.58))
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                Text("\(self.views.count)")
                            }.padding(2)
                            .padding(.horizontal, 8)
                            .background(Color(red: 0.137, green: 0.137, blue: 0.145))
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .robotoMono(.semibold, 17)
                    
            
                }
                .background {
                    Color("AdditionDarkBackground")
                }
                Divider().padding(0)
                
                // MARK: - Comments
                VStack(alignment: .leading) {
                    ForEach(self.modelComments) { comment in
                        CommentView(with: comment)
                    }
                }
                
                Text("")
                    .frame(height: 100)

            }
            .ignoresSafeArea(edges: .bottom)
            .onTapGesture { UIApplication.shared.hideKeyboard(); self.position = .relativeBottom(0.125); self.commentsTextFieldIsFirstResponder = false }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("AdditionDarkBackground"))
            .onChange(of: self.position, perform: { newValue in
                
                print(newValue)
                if newValue == .relativeTop(0.975) && self.textFieldHeight == 36 {
                    self.forceTopPosition = true
                }
                if newValue == .relativeBottom(0.125) || newValue == .relativeBottom(0.55) {
                    self.forceTopPosition = false
                }
                
                if newValue == .relativeBottom(0.125) {
                    UIApplication.shared.hideKeyboard()
                    self.commentsTextFieldIsFirstResponder = false
                } else {
                    self.commentsTextFieldIsFirstResponder = true
                }
            })
        .bottomSheet(bottomSheetPosition: self.$position, switchablePositions: [
                           .relativeBottom(0.125),
                           .relativeBottom(0.55),
                           .relativeTop(0.975)
                    ], headerContent: {
                        //A SearchBar as headerContent.
                        VStack {

                            MultilineTextFieldRepresentable(placeholder: "Add a comment",
                                                            text: self.$commentMessage,
                                                            contentHeight: self.$textFieldHeight,
                                                            maxContentHeight: 350.0,
                                                            responder: self.$commentsTextFieldIsFirstResponder, messageStateHandler: self.$messageEditingHandler,
                                                            onSend: {
                                self.messageEditingHandler = .sending
                                // MARK: - On send action
                                self.fsmanager.sendComment(postType: .Idea, postId: self.idea.id, author: self.loginUserID, text: self.commentMessage, image: nil) { result in
                                    switch result {
                                    case .success(let succ):
                                        self.messageEditingHandler = .done
                                        print("IdeaContentView: The comment was added successfully! The id is \(succ)")
                                        
                                        self.commentMessage = ""
                                        DispatchQueue.main.async {
                                            UIApplication.shared.hideKeyboard();
                                            self.position = .relativeBottom(0.125);
                                            self.commentsTextFieldIsFirstResponder = false
                                        }
                                        
                                    case .failure(let failure):
                                        self.messageEditingHandler = .done
                                        // TODO: - handle error
                                        print("IdeaContentView: Failed with uploading th ecomment! Error: \(failure)")
                                    }
                                }
                            })
                    
                                .robotoMono(.semibold, 15)
            
                                .frame(maxWidth: .infinity)
                                .frame(height: textFieldHeight)
                                .multilineTextAlignment(TextAlignment.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                 
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 5)
                
                        .padding([.horizontal, .bottom])

                        .onTapGesture {
                            self.position = .relativeBottom(0.55)
                        }
                    }) {

                        // MARK: - Content
                       
                    }
                    .enableAppleScrollBehavior()
                    .backgroundBlurMaterial(.systemDark)
//
        
        .onChange(of: self.page.index, perform: { newValue in
            if self.timer.isActive {
                self.timer.resetTimer()
            } else {
                withAnimation {
                    self.controlOpacity = 1
                }
                self.timer.startTimer {
                    withAnimation {
                        self.controlOpacity = 0
                    }
                }
            }
         
            
         
        })
        .onAppear {
          
            self.theIdeaWasStarredByTheLoginUser = self.idea.stars.contains(self.loginUserID)
            self.starYellowed = self.idea.stars.contains(self.loginUserID) ? 1 : 0
            
            self.theIdeaWasSavedByTheLoginUser = self.idea.saves.contains(self.loginUserID)
            self.bookmarkBlued = self.idea.saves.contains(self.loginUserID) ? 1 : 0
            
        }
        .onChange(of: self.commentMessage, perform: { _ in
            print("""

---------------------------------
\(self.commentMessage.count(of: "\n")) \(self.commentMessage.count)
---------------------------------

""")
        
            if self.textFieldHeight > 36 {
                self.position = .relativeTop(0.975)
            } else if !self.forceTopPosition {
                self.position = .relativeBottom(0.55)
            }
        })
        .task {
            if !self.idea.views.contains(self.loginUserID) {
                self.fsmanager.view(idea: self.idea.id, user: self.loginUserID)
            }
            self.fsmanager.getIdeaInfo(id: self.idea.id) { result in
                switch result {
                case .success(let statisticsData):
                    if let comments = statisticsData["comments"] as? Array<String>,
                       let views = statisticsData["views"] as? Array<String>,
                       let stars = statisticsData["stars"] as? Array<String>,
                       let saves = statisticsData["saves"] as? Array<String> {
                        
                        if comments != self.comments {
                            self.comments = comments
                            for _id in self.comments {
                                self.fsmanager.getComment(withID: _id) { result in
                                    
                                    switch result {
                                    case .success(let comment):
                                        let author = comment["author"] as? String
                                        let text = comment["text"] as? String
                                        let upvotes = comment["upvotes"] as? Array<String>
                                        let downvotes = comment["downvotes"] as? Array<String>
                                        let replies = comment["replies"] as? Array<String>
                                        let image = comment["image"] as? String
                                        let time = comment["time"] as? Double
                                        let date = comment["date"] as? String
                                        
                                        self.modelComments.append(Comment(author: author, text: text, upvotes: upvotes, downvotes: downvotes, replies: replies, image: image, time: time, date: date))
                                        
                                    case .failure(let failure):
                                        print("CommentView: Failed with getting comment: \(failure)")
                                    }
                                }
                            }
                        }
                        
                        self.stars = stars
                        self.views = views
                        self.saves = saves
                        
                        
                        
                        self.theIdeaWasSavedByTheLoginUser = saves.contains(self.loginUserID)
                        self.theIdeaWasStarredByTheLoginUser = stars.contains(self.loginUserID)
                        self.starYellowed = stars.contains(self.loginUserID) ? 1 : 0
                        self.bookmarkBlued = saves.contains(self.loginUserID) ? 1 : 0
                    }
                case .failure(let failure):
                    print("IdeaContentView:  cannot load IdeasListener \(failure.localizedDescription)")
                }
            
            }

        }
        .sheet(isPresented: self.$showCommentController, content: {
            Text("hh")
//                .presentationDetents([.medium, .large])
        })
      
        .publishOnTabBarAppearence(self.hideTabBar)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: self.$showAuthorProfileView, content: {
            ProfileView(with: self.idea.author, dismissable: true)
    
        })
    }}
      
    private func getTags(from string: String) -> [String] {
        return string.components(separatedBy: ", ")
    }
}


let TestIdea = Idea(id: "fdsafdas", author: "fdafdsa", title: "Написать замену Siri в виде горничной", text: "Кого только не бесит эта сфера, появившаяся ещё в 9 iOS? Хотелось бы иметь возможность убирать её, а так же ставить свои картинки из галереи. Если ещё реализуете возможность добавлять анимированные фотографии или видео - цены вам не будет!", category: FreelanceTopic.Development.rawValue, subcategory: FreelanceSubTopic.FreelanceDevelopingSubTopic.Offtop.rawValue, difficultyLevel: "Senior", skills: "iOS, jailbreak, Siri, AppCode, ARM-asm, gif", languages: [LangDescriptor.Logos.rawValue], images: [], files: [], time: 1244.1234, comments: [], stars: [], responses: [], views: [], saves: [], dateOfPublish: "6 Apr 09:31")

struct IdeaContentView_Previews: PreviewProvider {
    static var previews: some View {
        IdeaContentView(withIdea: TestIdea, hideTabBar: .constant(false))
    }
}
