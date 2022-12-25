//
//  ChatCells.swift
//  Coda
//
//  Created by Matoi on 24.12.2022.
//

import SwiftUI


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
  

    @State private var haveSeen: Bool?
    
    private let fsmanager: FSManager = FSManager()

    private var chatInfoCacher = NSCache<NSString, NSString>()
    private var chatMessageInfoCacher = NSCache<NSString, NSArray>()

    private func getInterlocutor(from members: [String]) -> String {
        members[0] == self.loginUserID ? members[1] : members[0]
    }

    init(with id: String) {
        self.id = id

        // Constant
        if let name: String = self.chatInfoCacher.object(forKey: "name:\(id)" as NSString) as? String {
            print("Loading from cache")
            self.userName = name
        }
        if let imageURL: String = self.chatInfoCacher.object(forKey: "imageURL:\(id)" as NSString) as? String {
            self.imageURL = imageURL
        }

        if let members: Array<String> = self.chatMessageInfoCacher.object(forKey: "members:\(id)" as NSString) as? Array<String> {
            self.members = members
        }

        // New with every message
        if let previewMessageID: String = self.chatInfoCacher.object(forKey: "previewMessageID:\(id)" as NSString) as? String {
            self.previewMessageID = previewMessageID
        }
        if let message: String = self.chatInfoCacher.object(forKey: "message:\(id)" as NSString) as? String {
            self.lastMessage = message
        }
        
        if let time: String = self.chatInfoCacher.object(forKey: "dayTime:\(id)" as NSString) as? String {
            self.time = time
        }
        if let haveSeen: Array<String> = self.chatMessageInfoCacher.object(forKey: "haveSeen:\(id)" as NSString) as? Array<String> {
            self.whoHaveSeen = haveSeen
        }
        if let sender: String = self.chatInfoCacher.object(forKey: "sender:\(id)" as NSString) as? String {
            self.sender = sender
        }

    }
    


    var body: some View {
        HStack {
            Group {
                if let url = self.imageURL {
                    CellImageView(urlString: url)
                } else {
                    ProgressView()
                }
            }
                .frame(width: 50, height: 50)
                .padding(.trailing, 6)
            
                    
            VStack(alignment: .leading) {
                Text(self.userName ?? "")
                        .foregroundColor(.primary)
                        .font(.custom("RobotoMono-Bold", size: 17))
                Text(self.lastMessage ?? "")
                        .foregroundColor(.secondary)
                        .font(.custom("RobotoMono-Bold", size: 12))
                Spacer()
            }
                    .fixedSize()
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
                        .font(.custom("RobotoMono-Bold", size: 13))
                Spacer()
            }
                    .fixedSize()
        }
                .task {
                    print(self.chatInfoCacher.object(forKey: "name:\(id)" as NSString))
                    if let name: String = self.chatInfoCacher.object(forKey: "name:\(id)" as NSString) as? String {
                        print("Loading from cache")
                        self.userName = name
                    }
                    if let imageURL: String = self.chatInfoCacher.object(forKey: "imageURL:\(id)" as NSString) as? String {
                        self.imageURL = imageURL
                    }

                    if let members: Array<String> = self.chatMessageInfoCacher.object(forKey: "members:\(id)" as NSString) as? Array<String> {
                        self.members = members
                    }
                    
                    if self.userName == nil {
                        await self.fsmanager.getChatInfo(of: ChatInfoProperties.all.rawValue, by: self.id) { result in
                            switch result {
                            case .success(let chatInfo):
                                self.members = chatInfo["members"]! as! Array<String>
                                self.chatMessageInfoCacher.setObject(self.members! as NSArray, forKey: "members")

                                Task {
                                    // Getting CHAT name and image
                                    if self.id[0..<4] == "chat" {
                                        let interlocutorID = self.getInterlocutor(from: self.members!)
                                        await self.fsmanager.getUserName(forID: interlocutorID) { nameResult in
                                            switch nameResult {
                                            case .success(let name):

                                                self.userName = name
                                                self.chatInfoCacher.setObject(name as NSString, forKey: "name:\(self.id)" as NSString)

                                            case .failure(let err):
                                                print("____ error!: \(err)")
                                            }
                                        }
                                        await self.fsmanager.getUserAvatar(withID: interlocutorID) { avatarResult in
                                            switch avatarResult {
                                            case .success(let url):
                                            
                                                self.imageURL = url
                                                self.chatInfoCacher.setObject(url as NSString, forKey: "imageURL:\(self.id)" as NSString)
                                                
                                                
                                                
                                                print(self.chatInfoCacher.object(forKey: "imageURL:\(self.id)" as NSString)!)
                                            case .failure(let err):
                                                print("______ error!: \(err)")
                                            }
                                        }
                                    }

                                    self.previewMessageID = (chatInfo["lastMessage"]! as! String)
                                    self.chatInfoCacher.setObject(self.previewMessageID! as NSString, forKey: "previewMessageID:\(id)" as NSString)
                                    print(self.chatInfoCacher.object(forKey: "previewMessageID:\(self.id)" as NSString)!)
                                    
                                    await self.fsmanager.getMessageInfo(id: (chatInfo["lastMessage"]! as! String), completion: { messageResult in
                                        switch messageResult {
                                        case .success(let messageInfo):
                                            self.whoHaveSeen = (messageInfo["whoHasRead"]! as! Array<String>)
                                            self.chatMessageInfoCacher.setObject(self.whoHaveSeen! as NSArray, forKey: "haveSeen:\(id)" as NSString)

                                            self.lastMessage = (messageInfo["body"]! as! String)
                                            self.chatInfoCacher.setObject(self.lastMessage! as NSString, forKey: "message:\(id)" as NSString)
                                            
                                            self.sender = (messageInfo["sender"]! as! String)
                                            self.chatInfoCacher.setObject(self.lastMessage! as NSString, forKey: "sender:\(id)" as NSString)
                                            
                                            self.time = (messageInfo["dayTime"]! as! String)
                                            self.chatInfoCacher.setObject(self.time! as NSString, forKey: "dayTime:\(id)" as NSString)
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
                    }
                }

    }
}

//struct ChatCell_Previews: PreviewProvider {

//    static var previews: some View {
//        ChatCell()
//    }
//}
