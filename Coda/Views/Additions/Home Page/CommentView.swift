//
//  CommentView.swift
//  Coda
//
//  Created by Matoi on 29.04.2023.
//

import SwiftUI

enum CommentType: String {
    case main, reply
}

struct CommentView: View {
    
    @AppStorage("avatarURL") var avatarURL: String = ""
    @AppStorage("LoginUserAvatarID") var loginUserAvatarID: String = ""
    @AppStorage("LoginUserID") var loginUserID: String = ""
    
    
    let comment: Comment
    let postID: String
    let type: CommentType
    let postType: PostType
    
    
    @Binding var openProfile: Bool
    @Binding var authorToOpenID: String
    @Binding var bottonSheetPosition: BottomSheetPosition
    @Binding var commentsTextFieldIsFirstResponder: Bool
    
    let onReplyAction: (_ author: String, _ name: String, _ rootCommentID: String) -> () // id пользователя, на чей комментарий отвечают, его имя, id комментария, который является главным в ветке
    let onRepliesExpandAction: (_ mainComment: Comment, _ replies: Array<Comment>) -> ()
    
    
    
    private let fsmanager: FSManager = FSManager()
    
    @State private var authorUsername: String = "Author Username"
    @State private var replierUsername: String = ""
    @State private var avatar: String? = nil
    
    @State private var replies: Array<String> = []
    @State private var repliesModel: Array<Comment> = []

    @State private var repliedName: String = ""
    @State private var expandReplies: Bool = false
    
    @State private var showConfirmationDialog: Bool = false
    
    @State private var scaleEffect: CGFloat = 1.0
    
        

    init(with comment: Comment, postID: String, type: CommentType = .main, postType: PostType, openProfile: Binding<Bool>, authorToOpenID: Binding<String>, BSPosition: Binding<BottomSheetPosition>, keyBoardResponder: Binding<Bool>,
         onReply: @escaping (_ author: String, _ name: String, _ rootCommentID: String) -> (),
         onExpand: @escaping (_ mainComment: Comment, _ replies: Array<Comment>) -> ()) {
        
        self.comment = comment
        self.type = type
        self.postID = postID
        self.postType = postType
        
        self._openProfile = openProfile
        self._authorToOpenID = authorToOpenID
        self._bottonSheetPosition = BSPosition
        self._commentsTextFieldIsFirstResponder = keyBoardResponder
        
        self.onReplyAction = onReply
        self.onRepliesExpandAction = onExpand
        
    }
    
    private var isDeleted: Bool {
        if let _type: String = self.comment.commentType, _type.components(separatedBy: " | ").count == 1 { return false }; return true
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack(alignment: .top) {
                if self.type == .reply {
                    Text("").frame(width: 44)
                }
                    // MARK: - Avatar
                if self.isDeleted {
                    Image("deleted")
                        .resizable()
                        .frame(width: self.type == .main ? 35 : 25, height: self.type == .main ? 35 : 25, alignment: .center)
                        .cornerRadius(20)
                        .padding(self.comment.commentType == "main" ? 4 : 0)
                } else {
                    CachedImageView(with: self.avatar, for: .Default)
                    .frame(width: self.type == .main ? 35 : 25, height: self.type == .main ? 35 : 25, alignment: .center)
                        .cornerRadius(20)
                        .padding(self.comment.commentType == "main" ? 4 : 0)
                }
               
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(self.isDeleted ? "[comment deleted]" : self.authorUsername)
                        Text(self.isDeleted ? "": self.repliedName)
                            .robotoMono(.light, 16, color: .secondary)
                            
                    }
                    .robotoMono(self.isDeleted ? .semibold : .bold, 16, color: self.isDeleted ? .secondary : .primary)
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                        .padding(.top, 4)
                    if !self.isDeleted, let text = self.comment.text {
                        // MARK: - Comment Body
                        Text(text)
                            .robotoMono(.medium, 14, color: .primary)
                    }
                    if !self.isDeleted, let imageURL = self.comment.image, imageURL != "" {
                        if self.type == .reply {
                          CachedImageView(with: imageURL, for: .Default)
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .frame(maxWidth: .infinity, maxHeight: 200, alignment: .leading)
                        }
                        else {
                            CachedImageView(with: imageURL, for: .Default)
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                
                             
                            
                                .frame(maxWidth: .infinity, maxHeight: 200, alignment: .leading)
                           
                                .padding(.vertical, 4)
                                .padding(.trailing)
                        }
                            
                    }
                    if !self.isDeleted, let date = self.comment.date {
                        HStack {
                            // MARK: - Date
                            Text(date)
                                .robotoMono(.light, 12, color: .secondary).padding(.top, 0)
                            // MARK: - Reply Button
                            Button {
                                print("Replay button on comment with text: \(self.comment.text!) tapped")
                                if let authorID = self.comment.author, let rootComment = self.comment.rootComment {
                                    self.onReplyAction(authorID, self.authorUsername, rootComment) // author передать в userBeingReplied
                                }
                                   
                            } label: {
                                Text("Reply")
                                    .robotoMono(.bold, 13, color: .secondary)
                                
                            }
                            Spacer()
                            
                            // MARK: - Upvotes && Downvotes
                            if !self.isDeleted {
                                HStack {
                                
                                    
                                    // MARK: - Post rate
                                    if let upvotes = self.comment.upvotes, let downvotes = self.comment.downvotes {
                                        // MARK: - Respect Button
                                        Button {
                                            self.fsmanager.like(comment: self.comment, user: self.loginUserID, postID: self.postID, type: self.postType)
                                        } label: {
                                            Image("arrowshape\(upvotes.contains(self.loginUserID) ? ".fill" : "")")
                                                .resizable()
                                                .frame(width: 18, height: 18)
                                                .rotationEffect(Angle(radians: .pi / 2))
                                                .foregroundColor(upvotes.contains(self.loginUserID) ? Color.purple : Color.secondary)
                                        }
                                        .font(.system(size: 12).bold())
                                        
                                        Text("\(upvotes.count - downvotes.count)")
                                            .font(.system(size: 14).bold())
                                            .foregroundColor(.secondary)
                                        // MARK: - Disrespect Button
                                        Button {
                                            self.fsmanager.unlike(comment: self.comment, user: self.loginUserID, postID: self.postID, type: self.postType)
                                        } label: {
                                
                                            Image("arrowshape\(downvotes.contains(self.loginUserID) ? ".fill" : "")")
                                                .resizable()
                                                .renderingMode(.template)
                                                .frame(width: 18, height: 18)
                                                .rotationEffect(Angle(radians: .pi / -2))
                                                .foregroundColor(downvotes.contains(self.loginUserID) ? Color.purple : Color.secondary)
                                            
                                        }
                                        .font(.system(size: 12).bold())
                                    }
                                   
                                 
                                    
                                }
                               
                                .fixedSize()
                            }
                        }
                        
                        
                        
                    }
                }
                Spacer()
            }
            .scaleEffect(self.scaleEffect)
            .padding(.bottom, 8)
            
            
            HStack {
                VStack {
                    if !self.repliesModel.isEmpty {
                        ForEach(0..<(self.repliesModel.count > 2 && !self.expandReplies ? 2 : self.repliesModel.count), id: \.self) { replyIndex in
                            CommentView(with: self.repliesModel[replyIndex], postID: self.postID, type: .reply, postType: .Idea, openProfile: self.$openProfile, authorToOpenID: self.$authorToOpenID, BSPosition: self.$bottonSheetPosition, keyBoardResponder: self.$commentsTextFieldIsFirstResponder, onReply: self.onReplyAction, onExpand: self.onRepliesExpandAction)
                        }
                        if self.replies.count > 2 {
                            HStack {
                                Text("").frame(width: 55)
                                Button {
                                    self.expandReplies.toggle()
                                } label: {
                                    HStack {
                                        Image(systemName: "chevron.compact.\(self.expandReplies ? "up" : "down")")
                                            .resizable()
                                            .frame(width: 15, height: 5)
                                            .foregroundColor(.secondary)
                                        Text(self.expandReplies ? "Collapse" : "Show All Replies")
                                            .robotoMono(.bold, 13)
                
                                    }
                              
                                }.fixedSize()
                                Spacer()
                            }
                        }
                        // MARK: - Comment Reply Button
                        HStack {
                            Text("").frame(width: 40)
                            Button {
                                if let authorID = self.comment.author, let rootComment = self.comment.rootComment {
                                    self.onReplyAction(authorID, self.authorUsername, rootComment) // author передать в userBeingReplied
                                }
                               
                            } label: {
                                HStack {
                                    CachedImageView(with: self.loginUserAvatarID, for: .Default)
                                        .frame(width: 25, height: 25)
                                        .cornerRadius(20)
                                        .padding(4)
                                    RoundedRectangle(cornerRadius: 25)
                                        .foregroundColor(.black)
                                        .frame(height: 25)
                                        .frame(maxWidth: .infinity)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color.secondary, style: .init(lineWidth: 1))
                                        }
                                        .overlay {
                                            HStack { Text("Comment").robotoMono(.bold, 14, color: .secondary).offset(x: 8); Spacer() }
                                        }
                                }
                            }
                        }

                   
                    }
                }
            }
            
          
        }
        .confirmationDialog("__comment_View_arg_dialog", isPresented: self.$showConfirmationDialog, actions: {
            
            if let authorID = self.comment.author, authorID == self.loginUserID {
                // MARK: - Edit Button
                Button {
                    
                } label: {
                    Text("Edit")
                }
            }
          
            // MARK: - Like/dislike
            if let upvotes = self.comment.upvotes, let downvotes = self.comment.downvotes {
                if !upvotes.contains(self.loginUserID) && !downvotes.contains(self.loginUserID) {
                    Button {
                        self.fsmanager.like(comment: self.comment, user: self.loginUserID, postID: self.postID, type: self.postType)
                    } label: {
                        Text("Like")
                    }
                    Button {
                        self.fsmanager.unlike(comment: self.comment, user: self.loginUserID, postID: self.postID, type: self.postType)
                    } label: {
                        Text("Dislike")
                    }
                } else if upvotes.contains(self.loginUserID) {
                    Button {
                        self.fsmanager.unlike(comment: self.comment, user: self.loginUserID, postID: self.postID, type: self.postType)
                    } label: {
                        Text("Dislike")
                    }
                } else {
                    Button {
                        self.fsmanager.like(comment: self.comment, user: self.loginUserID, postID: self.postID, type: self.postType)
                    } label: {
                        Text("Like")
                    }
                }
             
            }
     
            if let text = self.comment.text, !text.isEmpty {
                Button {
                    UIPasteboard.general.string = text
                } label: {
                    Text("Copy")
                }
            }
      

            
            // MARK: - Open Profile button
            if let authorID = self.comment.author {
                Button {
                   
                        self.authorToOpenID = authorID
                        self.openProfile = true
              
                } label: {
                    Text(self.authorUsername)
                }
            }
            
            if let _ = self.comment.author, let replierID = self.comment.personBeingReplied, !self.replierUsername.isEmpty, self.authorUsername != self.replierUsername {
            Button {
         
                self.authorToOpenID = replierID
                    self.openProfile = true
                    
                } label: {
                    Text(self.replierUsername)
                }
            }
            
            // MARK: - Delete
            if !self.isDeleted,
               let authorID: String = self.comment.author, authorID == self.loginUserID {
                Button("Delete", role: .destructive) {
                    self.showConfirmationDialog = false
                    if let id = self.comment.commentID {
                        self.fsmanager.remove(comment: id, post: self.postID, type: self.postType) { result in
                            switch result {
                            case .success(let success):
                                print(success)
                            case .failure(let failure):
                                print(failure)
                            }
                        }
                    }
                 
                }
            }

        })
        .padding(.horizontal, self.type == .main ? 8 : 0)
        .frame(maxWidth: .infinity)
        .background { Color("AdditionDarkBackground") }
        .task {
            if let personID = self.comment.personBeingReplied, personID != "" {
                self.fsmanager.getUserName(forID: personID, completion: { res in
                    switch res {
                    case .success(let success):
                        self.repliedName = success
                    case .failure(let failure):
                        print("CommentView: Error with getting username: \(failure)")
                    }
                    
                })
            }
           
        }
        .task {
            if let replies = self.comment.replies, replies != self.replies {
                self.replies = replies
                self.repliesModel = []
                for _id in self.replies {
                    
                        self.fsmanager.getComment(withID: _id) { result in
                            
                            switch result {
                            case .success(let comment):
                                
                                let commentID = comment["commentID"] as? String
                                let author = comment["author"] as? String
                                let text = comment["text"] as? String
                                let upvotes = comment["upvotes"] as? Array<String>
                                let downvotes = comment["downvotes"] as? Array<String>
                                let replies = comment["replies"] as? Array<String>
                                let image = comment["image"] as? String
                                let time = comment["time"] as? Double
                                let date = comment["date"] as? String
                                let commentType = comment["commentType"] as? String
                                let rootComment = comment["rootComment"] as? String
                                
                                let personBeingReplied = comment["personBeingReplied"] as? String
                                
                                self.repliesModel.append(Comment(commentID: commentID, personBeingReplied: personBeingReplied, rootComment: rootComment, commentType: commentType, author: author, text: text, upvotes: upvotes, downvotes: downvotes, replies: replies, image: image, time: time, date: date))
                                
                            case .failure(let failure):
                                print("CommentView: Failed with getting reply: \(failure)")
                            }
                        }
                }
                    }
        }
        .task {
            
            // получение имени автора текущего комментария
            if let authorID =  self.comment.author {
                await self.fsmanager.getUserInfo(forID: authorID) { res in
                    switch res {
                    case .success(let userData):
                        
                        self.avatar = (userData["avatarURL"] as! String)
                        self.authorUsername = (userData["username"] as! String)
                        
                    case .failure(let failure):
                        print("CommentView: \(failure.localizedDescription)")
                    }
                }
                
            }
            
            // Получение имени человека, на комментарий которого мы ответили
            if self.type == .reply {
                if let rootCommentAuthorID = self.comment.personBeingReplied, !rootCommentAuthorID.isEmpty {
                    await self.fsmanager.getUserInfo(forID: rootCommentAuthorID) { res in
                        switch res {
                        case .success(let userData):
                            
                            self.replierUsername = (userData["username"] as! String)
                            
                        case .failure(let failure):
                            print("CommentView: \(failure.localizedDescription)")
                        }
                    }
                }
            }
            
        }
    
        .onTapGesture {
            
            if self.commentsTextFieldIsFirstResponder {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil)
                self.bottonSheetPosition = .relativeBottom(0.125)
                self.commentsTextFieldIsFirstResponder = false
                print("Hey")
            } else {
                if !self.isDeleted {
                    withAnimation(Animation.easeInOut(duration: 1)) {
                        self.scaleEffect = 0.2
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                            withAnimation {
                                self.scaleEffect = 1
                            }
                           
                        }
                    }
                    self.showConfirmationDialog = true
                    
                }
            }
        }
    }
}

struct CommentView_Previews: PreviewProvider {

    @State private var toggleExample: Bool = false

    static var previews: some View {
        CommentView(with: Comment(commentID: "", personBeingReplied: "", rootComment: "self", commentType: "main", author: "fsafas", text: "The comment's body", upvotes: ["fdsfsa"], downvotes: [], replies: [], image: "dfs", time: 17712747172.00042, date: "9 Apr at 21:05"), postID: "", postType: .Idea, openProfile: .constant(false), authorToOpenID: .constant(""), BSPosition: .constant(BottomSheetPosition.relativeBottom(0.125)), keyBoardResponder: .constant(false)) { authorID, authorName, rootCommentID  in
            print(authorID, authorName, rootCommentID)
        } onExpand: { mainComment, replies in
            print(mainComment.text ?? "log")
            
        }
    }
}
