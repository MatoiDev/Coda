//
//  Chat.swift
//  Coda
//
//  Created by Matoi on 24.12.2022.
//

import SwiftUI
import Cachy
import Introspect

struct Chat: View {
    
    // To scroll to bottom always
    @Namespace var bottomID
    
    // For creating new Message
    @State var messageText: String = ""
    
    @State private var pinImage: Bool = false
    @State private var pinnedPhoto: UIImage?
    
    @State private var messageData: Dictionary<String, Any>?
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @AppStorage("LoginUserID") var loginUserID: String = ""
    
    // Для того, чтобы не загружать 150 раз одну и ту же картинку
    @State private var imageDidChange: Bool = false
    
    private let fsmanager: FSManager = FSManager()
    
    @State private var showProfile: Bool = false
    @State var editMessage: Bool = false
    
    @State private var editBarText: String?
    @State var currentEditMessageID: String = ""
    @State var imageOptionalID: String = ""
    @State var messageImage: UIImage = UIImage()
   
    // Chat initialization
    var id: String
    @State private var chatName: String?
    
    // Chat properties
    @State private var messages: [String]?
    @State private var imageURL: String?
    @State private var members: Array<String>?
    @State private var interlocutorID: String?
    
    // For hiding TabBar
    @Binding var hideTabBar: Bool

    init(with id: String, tabbarObserver: Binding<Bool>) {
        
        self.id = id
        self._hideTabBar = tabbarObserver
        self.tryToGetMessages()

    }
    
    private func getInterlocutor(from members: [String]) -> String {
        members[0] == self.loginUserID ? members[1] : members[0]
    }
    
    private func tryToGetMessages() -> Void {
        if let messages: Array<String> = Cachy.shared.get(forKey: "messages:\(self.id)") {
            print("Loading messages from cache, \(messages)")
            self.messages = messages
        }
    }
    
    private func tryToGetAll() -> Void {

        if let members: Array<String> = Cachy.shared.get(forKey: "members:\(self.id)") {
            print("Loading members from cache in chat, \(members)")
            self.members = members
        }
        
        if let chatName: String = Cachy.shared.get(forKey: "chatName:\(self.id)") {
            print("Chat name loaded from cache in chat view controller")
            self.chatName = chatName
        }
        
        if let interlocutorID: String = Cachy.shared.get(forKey: "interlocutorID:\(self.id)") {
            self.interlocutorID = interlocutorID
        }
        
    }
    

    var body: some View {
        
        ScrollViewReader { proxy in
            VStack {
                
                
                if let mgs = self.messages {
                    
                    List {
                        Section {
                            ForEach(mgs, id: \.self) { ind in
                                // MARK: - Cached message
                                if let messageData: Dictionary<String, Any> = Cachy.shared.get(forKey: "messageData:\(ind)") {
                                    
                                    let senderID: String = messageData["sender"]! as! String
                                    let dayTime: String = messageData["dayTime"]! as! String
                                    let body: String = messageData["body"]! as! String
                                    let imageID: String = messageData["image"] as! String
                                    let wasEdited = (messageData["didEdit"]! as! String) == "true"
                                    
                                    
                                    if senderID != self.loginUserID {
                                        // MARK: - Cached Left message
                                        MessageBubble(id: ind, direction: .left, time: dayTime, wasEdited: wasEdited, editTrigger: self.$editMessage, message: self.$messageText, editMessageID: self.$currentEditMessageID, imageOptionalID: self.$imageOptionalID, uiMessageImage: self.$messageImage) {
                                            VStack {
                                                if imageID != "" {
                                                    let CCImageView : CachedImageView = CachedImageView(with: imageID, for: .Message)
                                                    CCImageView
                                                        .onAppear {
                                                            if let image = CCImageView.urlImageModel.image {
                                                                self.messageImage = image
                                                            }
                                                        }
                                                }
                                                if body != "" {
                                                    HStack {
                                                        Text(LocalizedStringKey(body))
                                                            
                                                            .robotoMono(.semibold, 15, color: .white)
                                                            .padding(.all, 10)
                                                            .padding(.leading, 4)
                                                            
                                                        if imageID != "" {
                                                            Spacer()
                                                        }
                                                    }
                                                }
                                            }
                                        }.id(ind)
                                    } else {
                                        let whoHasRead = messageData["whoHasRead"] as! Array<String>
                                        // MARK: - Cached Right message
                                        MessageBubble(id: ind, direction: .right, time: dayTime, checked: whoHasRead.count != 0, wasEdited: wasEdited, editTrigger: self.$editMessage, message: self.$messageText, editMessageID: self.$currentEditMessageID, imageOptionalID: self.$imageOptionalID, uiMessageImage: self.$messageImage) {
                                            VStack {
                                                if imageID != "" {
//                                                    ChatCachedImageView(with: imageID, for: .Message)
                                                    let CCImageView : CachedImageView = CachedImageView(with: imageID, for: .Message)
                                                    CCImageView
                                                        .onAppear {
                                                            if let image = CCImageView.urlImageModel.image {
                                                                self.messageImage = image
                                                            }
                                                        }
                                                }
                                                    if body != "" {
                                                        HStack {
                                                            Text(LocalizedStringKey(body))

                                                            .robotoMono(.semibold, 15, color: .white)
                                                            .padding(.all, 10)
                                                    
                                                        if imageID != "" {
                                                            Spacer()
                                                        }
                                                    }
                                                }
                                            }
                                        }.id(ind)
                                    }
                                } else {
                                    // MARK: - Non-cached message
                                    MessageBubble(id: ind, editTrigger: self.$editMessage, message: self.$messageText, editMessageID: self.$currentEditMessageID, imageOptionalID: self.$imageOptionalID, uiMessageImage: self.$messageImage) {
                                        Text("stub")
                                    }.id(ind)
                                }
                            }
                        }.onAppear {
                            UITableView.appearance().separatorColor = .clear
                            UITableView.appearance().showsVerticalScrollIndicator = false
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        
                    }
                    .onTapGesture {
                        UIApplication.shared.hideKeyboard()
                    }
                    .listStyle(.plain)
                    .onAppear {
                        UITableView.appearance().separatorColor = .clear
                        UITableView.appearance().showsVerticalScrollIndicator = false
                    }
                    .onReceive(mgs.publisher) { _ in
                        guard !mgs.isEmpty, let lastMessageID = mgs.last else { return }
                        print(mgs.last!, mgs.count)
                        
                        Task {
                            withAnimation {
                                proxy.scrollTo(lastMessageID, anchor: .bottom)
                            }
                            
                        }
                    }
                    
                    VStack {
                        if self.editMessage {
                            HStack {
                                Image(systemName: "pencil")
                                    .robotoMono(.semibold, 20)
                                Divider()
                                    .foregroundColor(Color("Register2"))
                                    .frame(width: 3)
                                    .padding(.vertical, 2)
                                VStack(alignment: .leading) {
                                    Text("Edit message")
                                    
                                    Text(self.editBarText ?? "")
                                        .foregroundColor(Color.primary)

                                        .robotoMono(.semibold, 13, color: .primary)
                                        .onAppear {
                                            self.editBarText = self.editBarText == nil ? self.messageText : self.editBarText
                                        }
                                }
                                Spacer()
                                Button {
                                    withAnimation {
                                        self.editMessage = false
                                        self.imageDidChange = false
                                        
                                        self.messageText = ""
                                        self.currentEditMessageID = ""
                                        self.imageOptionalID = ""
                                        
                                        self.messageImage = UIImage()
                                        
                                        self.editBarText = nil
                                        self.pinnedPhoto = nil
                                    }
                                    
                                } label: {
                                    Image(systemName: "multiply")
                                }
                                .robotoMono(.semibold, 20)
                            
                            
                            }
                                .robotoMono(.semibold, 15, color: Color("Register2"))
                                .fixedSize(horizontal: false, vertical: true)
                            
                            if self.messageImage != UIImage() {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: self.messageImage)
                                        .resizable()
                                        .frame(width: 150, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.secondary, lineWidth: 3)
                 
                                        }
                                    Button {
                                        withAnimation {
                                            self.pinnedPhoto = nil
                                            self.messageImage = UIImage()
                                        }
                                        
                                    } label: {
                                        Image(systemName: "trash.circle.fill")
                                            .symbolRenderingMode(.hierarchical)
                                            .resizable()
                                            .foregroundColor(Color.red)
                                            .frame(width: 20, height: 20)
                                            
                                    }.padding(8)

                                }
                            }
                        }
                        
                        if let pinnedPhoto = self.pinnedPhoto {
    
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: pinnedPhoto)
                                    .resizable()
                                    .frame(width: 150, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.secondary, lineWidth: 3)
             
                                    }
                                Button {
                                    withAnimation {
                                        self.pinnedPhoto = nil
                                        self.messageImage = UIImage()
                                    }
                                    
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .symbolRenderingMode(.hierarchical)
                                        .resizable()
                                        .foregroundColor(Color.primary)
                                        .frame(width: 20, height: 20)
                                        
                                }.padding(8)

                            }

                        
                    }
                    HStack {
                        // MARK: - Pin\change image Button
                    
                        VStack {
                            Spacer()
                            Button {
                                self.pinImage.toggle()
                            } label: {
                                Image(systemName: self.editMessage ?
                                      self.messageImage != UIImage() ? "arrow.triangle.2.circlepath.circle.fill" : "paperclip.circle.fill" :
                                        self.pinnedPhoto == nil ? "paperclip.circle.fill" : "arrow.triangle.2.circlepath.circle.fill")
                                    .resizable()
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundColor(.secondary)
                                    .frame(width: 35, height: 35)
                            }
                        }
                        // MARK: - Message Typer
                        ChatMessageTyper(messageText: self.$messageText)
                            .padding(.top, 8)
                        // MARK: - Edit message mode
                        if self.editMessage {
                            // MARK: - Edit message button
                            VStack {
                                Spacer()
                                Button {
    //                                guard self.messageText != "" || self.messageImage != UIImage() else { return }
                                    self.fsmanager.editMessage(self.currentEditMessageID, body: self.messageText, image: self.messageImage == UIImage() ? nil : self.messageImage, messageImageID: self.imageOptionalID, imageDidChange: self.imageDidChange) { res in
                                        switch res {
                                        case .success(_):
                                            withAnimation {
                                                self.editMessage = false
                                                self.imageDidChange = false
                                                
                                                self.messageText = ""
                                                self.currentEditMessageID = ""
                                                self.imageOptionalID = ""
                                                
                                                self.messageImage = UIImage()
                                                
                                                
                                                self.editBarText = nil
                                                self.pinnedPhoto = nil
                                            }
                                        case .failure(let err):
                                            print("___ need an error handler: \(err)")
                                        }
                                        
                                    }
                                } label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .resizable()
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundColor(Color("Register2"))
                                        .frame(width: 35, height: 35)
                                }
                                .disabled(self.messageText.isEmpty && self.messageImage == UIImage())
                                
                            }
                        } else {
                            // MARK: - Send message button
                            VStack {
                                Spacer()
                                Button {
                                    self.fsmanager.sentMessage(chat: self.id, body: self.messageText, image: self.pinnedPhoto) { result in
                                        switch result {
                                        case .success(let success):
                                            print(success)
                                            
                                            withAnimation {
                                                self.editMessage = false
                                                self.imageDidChange = false
                                                
                                                self.messageText = ""
                                                self.currentEditMessageID = ""
                                                self.imageOptionalID = ""
                                                
                                                self.messageImage = UIImage()
                                                
                                                self.editBarText = nil
                                                self.pinnedPhoto = nil
                                            }
                                            
                                        case .failure(let failure):
                                            print(failure)
                                        }
                                    }
                                    
                                } label: {
                                    Image(systemName: "paperplane.circle.fill")
                                        .resizable()
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundColor(Color("Register2"))
                                        .frame(width: 35, height: 35)
                                }.disabled(self.messageText.isEmpty && self.pinnedPhoto == nil)
                            }
                        }
                        
                        
                    }.fixedSize(horizontal: false, vertical: true)
//                            .padding(.top, 4)
                    
                }.padding(.horizontal)
                        .padding(.bottom, 4)
                        .background(Color("TyperKeyPadColor"))
                        .overlay {
                            VStack {
                                Divider()
                            }.frame(maxHeight: .infinity, alignment: .top)
                            
                        }
                    
                } else {
                    ProgressView()
                        .navigationBarTitleDisplayMode(.inline)
                        .listStyle(.plain)
                        .navigationBarHidden(false)
                }
                
            }
            .sheet(isPresented: self.$pinImage, content: {
                ImagePicker(sourceType: .photoLibrary) { res in
                    switch res {
                    case .success(let img):
                        if self.editMessage {
                            self.messageImage = img
                        } else {
                            self.pinnedPhoto = img
                        }
                        
                        self.imageDidChange = true
                    case .failure(let err):
                        print("___ error with picking photo in mwssage: \(err)")
                    }
                }
            })

            .onAppear {
                self.hideTabBar = true

            }
     
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if let chatName = self.chatName {
                        Text(chatName)
                            .robotoMono(.semibold, 20)
                    } else {
                        ProgressView()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    Button {
                        self.showProfile.toggle()
                    } label: {
                        Group {
                            if let imageURL: String = self.imageURL {
                                CachedImageView(with: imageURL, for: .ChatIntelocutorLogo)
                            } else {
                                Circle()
                                    .fill(Color.secondary)
                            }
                        }.frame(width: 35, height: 35)
                            .padding(.vertical)
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 1)
                                    .fill(Color.secondary)
                                
                            }
                    }
                    
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action : {
                self.hideTabBar = false
                self.mode.wrappedValue.dismiss()
            }){
                HStack {
                    if #available(iOS 16.0, *) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.cyan)
                            .fontWeight(.bold)
                    } else {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.cyan)
                    }
                }
                
            })
            .task {
                
                self.tryToGetAll()
                if self.members == nil, let members: Array<String> = Cachy.shared.get(forKey: "members:\(self.id)") { self.members = members }
                if self.chatName == nil {
                    if let members = self.members {
                        print("here are members \(members)")
                        let interlocutorID = self.getInterlocutor(from: members)
                        self.interlocutorID = interlocutorID
                        
                        self.fsmanager.getUserName(forID: interlocutorID, completion: { res in
                            switch res {
                            case .success(let name):
                                
                                self.chatName = name
            
                                let chatNameObject = CachyObject(value: name as NSString, key: "chatName:\(self.id)")
                                let interlocutorIDObject = CachyObject(value: interlocutorID as NSString, key: "interlocutorID:\(self.id)")
                                
                                Cachy.shared.add(object: chatNameObject)
                                Cachy.shared.add(object: interlocutorIDObject)
                                
                            case .failure(let failure):
                                print("___Neef to trigger an error: \(failure)")
                            }
                        })
                    } else {
                        if self.members == nil, let members: Array<String> = Cachy.shared.get(forKey: "members:\(self.id)") { self.members = members }
                    }
                    
                }
                
                if self.imageURL == nil {
                    self.imageURL = Cachy.shared.get(forKey: "imageURL:\(self.id)")
                }
               
                print(proxy)
                if self.messages == nil {
                    await self.fsmanager.getChatInfo(of: ChatInfoProperties.all.rawValue, by: self.id, completion: { res in
                        switch res {
                        case .success(let chatInfo):
                            self.messages = (chatInfo["messages"]! as! Array<String>)
                            let messagesObject: CachyObject = CachyObject(value: self.messages! as NSArray, key: "messages:\(self.id)")
                            Cachy.shared.add(object: messagesObject)
                        case .failure(let failure):
                            
                            print("__________ trigger error: \(failure)")
                        }
                    })
                } else {
                    print("else proxy scrolling")
                }
            }
        }
//        .publishOnTabBarAppearence(self.hideTabBar)

    
        .fullScreenCover(isPresented: self.$showProfile) {
            if let interlocutorID = self.interlocutorID {
                ProfileView(with: interlocutorID)
            }
        }
    }
}

