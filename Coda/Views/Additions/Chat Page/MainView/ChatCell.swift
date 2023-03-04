//
//  ChatCells.swift
//  Coda
//
//  Created by Matoi on 24.12.2022.
//

import SwiftUI
import Cachy

enum ChatInfoProperties: String {
    case all
    case id
    case members
    case lastMessage
    case name
    case messages
}


struct ChatCell: View {
    
    @AppStorage("LoginUserID") var loginUserID: String = ""
    
    var id: String
    
    @State private var userName: String?
    @State private var previewMessageID: String?
    @State private var lastMessage: String?
    @State private var time: String?
    @State private var whoHaveSeen: Array<String>?
    @State private var imageURL: String?
    @State private var image: UIImage?
    @State private var members: Array<String>?
    @State private var sender: String?
    
    @State private var messageImageURL: String?
    
    
    @State private var haveSeen: Bool?
    
    private let fsmanager: FSManager = FSManager()
    
    private var chatInfoCacher = NSCache<NSString, NSString>()
    private var chatMessageInfoCacher = NSCache<NSString, NSArray>()
    
    private func getInterlocutor(from members: [String]) -> String {
        members[0] == self.loginUserID ? members[1] : members[0]
    }
    
    init(with id: String) {
        self.id = id
        self.tryToGetAllFromCache()
    }
    
    private func tryToGetAllFromCache() -> Void {
        // Constant
        if let name: String = Cachy.shared.get(forKey: "name:\(id)") {
            print("Loading name from cache, \(name)")
            self.userName = name
        }
        if let imageURL: String = Cachy.shared.get(forKey: "imageURL:\(id)") {
            print("Loading imageURL from cache, \(imageURL)")
            self.imageURL = imageURL
        }
        
        if let members: Array<String> = Cachy.shared.get(forKey: "members:\(self.id)") {
            print("Loading members from cache, \(members)")
            self.members = members
        }
        
        // New with every message
        if let previewMessageID: String = Cachy.shared.get(forKey: "previewMessageID:\(id)" ) {
            print("Loading previewMessageID from cache, \(previewMessageID)")
            self.previewMessageID = previewMessageID
        }
        if let message: String = Cachy.shared.get(forKey: "message:\(id)") {
            print("Loading message from cache, \(message)")
            self.lastMessage = message
        }
        
        if let time: String = Cachy.shared.get(forKey: "dayTime:\(id)") {
            print("Loading dayTime from cache, \(time)")
            self.time = time
        }
        if let haveSeen: Array<String> = Cachy.shared.get(forKey: "haveSeen:\(id)") {
            print("Loading haveSeen from cache, \(haveSeen)")
            self.whoHaveSeen = haveSeen
        }
        if let sender: String = Cachy.shared.get(forKey: "sender:\(id)") {
            print("Loading sender from cache, \(sender)")
            self.sender = sender
        }
        
        if let messageImageURL: String = Cachy.shared.get(forKey: "messageImageURL:\(id)") {
            self.messageImageURL = messageImageURL
        }
        
    }
    
    var body: some View {
        HStack {
            Group {
                if let url = self.imageURL {
                    ChatCachedImageView(with: url, for: .Cell)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 50, height: 50)
            .padding(.trailing, 6)
            
            
            VStack(alignment: .leading) {
                Text(self.userName ?? "")
                    .robotoMono(.bold, 17)
                if let messageImageURL = self.messageImageURL, messageImageURL != "" {
                    HStack {
                        ChatCachedImageView(with: messageImageURL, for: .CellMessage)
                            .fixedSize()
                        if let lastMessage = self.lastMessage, lastMessage.isEmpty {
                            Text("Photo")
                                .robotoMono(.bold, 12, color: .secondary)
                        } else {
                            Text(self.lastMessage != nil ? self.lastMessage!.count > 16 ? self.lastMessage![0..<16] + "..." : self.lastMessage! : "")
                                .robotoMono(.bold, 12, color: .secondary)
                        }
                       
                    }.offset(y:-5)
                } else {
                    Text(self.lastMessage != nil ? self.lastMessage!.count > 21 ? self.lastMessage![0..<21] + "..." : self.lastMessage! : "")
                        .robotoMono(.bold, 12, color: .secondary)
                }
                
                Spacer()
            }
            .frame(height: 10)
//            .fixedSize()
            Spacer()
            VStack {
                HStack {
                    if let whoHaveSeen = self.whoHaveSeen, let members = self.members, let sender = self.sender {
                        if sender != self.loginUserID {
                            if !whoHaveSeen.contains(self.loginUserID) {
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .frame(width: 10, height: 10)
                                    .foregroundStyle(LinearGradient(colors: [.cyan, Color("Register2")], startPoint: .topLeading, endPoint: .bottomTrailing))
                            }
                        } else {
                            Image(whoHaveSeen.contains(self.getInterlocutor(from: members)) ? "tick.double" : "tick")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(LinearGradient(colors: [.cyan, Color("Register2")], startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                        
                    } else {
                        EmptyView()
                    }
                    if let time = self.time {
                        Text(time)
                    } else {
                        EmptyView()
                    }
                }
                .colorMultiply(.secondary)
                .robotoMono(.bold, 13, color: .secondary)
                Spacer()
            }
            .fixedSize()
        }
        .task {
            
            self.tryToGetAllFromCache()
            if self.userName == nil {
                await self.fsmanager.getChatInfo(of: ChatInfoProperties.all.rawValue, by: self.id) { result in
                    switch result {
                    case .success(let chatInfo):
                        self.members = (chatInfo["members"]! as! Array<String>)
                        let messages = (chatInfo["messages"]! as! Array<String>)
                        
                        let membersObject = CachyObject(value: self.members! as NSArray, key: "members:\(self.id)")
                        let messagesObject: CachyObject = CachyObject(value: messages as NSArray, key: "messages:\(self.id)")
                        
                        Cachy.shared.add(object: messagesObject)
                        Cachy.shared.add(object: membersObject)
                        
                        Task {
                            // Getting CHAT name and image
                            if self.id[0..<4] == "chat" {
                                let interlocutorID = self.getInterlocutor(from: self.members!)
                                await self.fsmanager.getUserName(forID: interlocutorID) { nameResult in
                                    switch nameResult {
                                    case .success(let name):
                                        
                                        self.userName = name
                                        let nameObject = CachyObject(value: name as NSString, key: "name:\(self.id)")
                                        Cachy.shared.add(object: nameObject)
                                        
                                    case .failure(let err):
                                        print("____ error!: \(err)")
                                    }
                                }
                                await self.fsmanager.getUserAvatar(withID: interlocutorID) { avatarResult in
                                    switch avatarResult {
                                    case .success(let url):
                                        
                                        self.imageURL = url
                                        let avatarObject = CachyObject(value: url as NSString, key: "imageURL:\(self.id)")
                                        Cachy.shared.add(object: avatarObject)
                                        
                                    case .failure(let err):
                                        print("______ error!: \(err)")
                                    }
                                }
                            }
                            
                            self.previewMessageID = (chatInfo["lastMessage"]! as! String)
                            let previewMessageObject = CachyObject(value: self.previewMessageID! as NSString, key: "previewMessageID:\(self.id)")
                            Cachy.shared.add(object: previewMessageObject)
                            
                            
                            await self.fsmanager.getMessageInfo(id: (chatInfo["lastMessage"]! as! String), completion: { messageResult in
                                switch messageResult {
                                case .success(let messageInfo):
                                    self.whoHaveSeen = (messageInfo["whoHasRead"]! as! Array<String>)
                                    let whoReadObject = CachyObject(value: self.whoHaveSeen! as NSArray, key: "haveSeen:\(self.id)")
                                    Cachy.shared.add(object: whoReadObject)
                                    
                                    self.lastMessage = (messageInfo["body"]! as! String)
                                    let lastMessageObject = CachyObject(value: self.lastMessage! as NSString, key: "message:\(self.id)")
                                    Cachy.shared.add(object: lastMessageObject)
                                    
                                    
                                    self.sender = (messageInfo["sender"]! as! String)
                                    let senderObject = CachyObject(value: self.sender! as NSString, key: "sender:\(self.id)")
                                    Cachy.shared.add(object: senderObject)
                                    
                                    
                                    self.time = (messageInfo["dayTime"]! as! String)
                                    let timeObject = CachyObject(value: self.time! as NSString, key: "dayTime:\(self.id)")
                                    Cachy.shared.add(object: timeObject)
                                    
                                    self.messageImageURL = (messageInfo["image"]! as! String)
                                    let messageImageURLObject = CachyObject(value: self.messageImageURL! as NSString, key: "messageImageURL:\(self.id)")
                                    Cachy.shared.add(object: messageImageURLObject)
                                    
                                case .failure(let err):
                                    print("Fucking here")
                                    print("__________ trigger error: \(err)")
                                }
                            })
                        }
                        
                        
                        
                        
                    case .failure(let err):
                        print("__________ trigger error: \(err)")
                    }
                }
            } else {
                await self.fsmanager.getMessageInfo(id: self.previewMessageID!, completion: { messageResult in
                    switch messageResult {
                    case .success(let messageInfo):
                        self.whoHaveSeen = (messageInfo["whoHasRead"]! as! Array<String>)
                        let whoReadObject = CachyObject(value: self.whoHaveSeen! as NSArray, key: "haveSeen:\(self.id)")
                        Cachy.shared.add(object: whoReadObject)
                        
                        self.lastMessage = (messageInfo["body"]! as! String)
                        let lastMessageObject = CachyObject(value: self.lastMessage! as NSString, key: "message:\(self.id)")
                        Cachy.shared.add(object: lastMessageObject)
                        
                        
                        self.sender = (messageInfo["sender"]! as! String)
                        let senderObject = CachyObject(value: self.sender! as NSString, key: "sender:\(self.id)")
                        Cachy.shared.add(object: senderObject)
                        
                        
                        self.time = (messageInfo["dayTime"]! as! String)
                        let timeObject = CachyObject(value: self.time! as NSString, key: "dayTime:\(self.id)")
                        Cachy.shared.add(object: timeObject)
                        
                        self.messageImageURL = (messageInfo["image"]! as! String)
                        let messageImageURLObject = CachyObject(value: self.messageImageURL! as NSString, key: "messageImageURL:\(self.id)")
                        Cachy.shared.add(object: messageImageURLObject)
                        
                        
                        self.tryToGetAllFromCache()
                    case .failure(let err):
                        print("Fucking here")
                        print("__________ trigger error: \(err)")
                    }
                })
            }
        }
        
    }
}

//struct ChatCell_Previews: PreviewProvider {
//
//    static var previews: some View {
//        ChatCell()
//    }
//}
