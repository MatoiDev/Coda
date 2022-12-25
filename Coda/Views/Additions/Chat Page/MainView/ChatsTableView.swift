//
//  ChatView.swift
//  Coda
//
//  Created by Matoi on 30.10.2022.
//

import SwiftUI


struct ChatsTableView: View {
//    var chats: [ChatCell] = [
//        ChatCell(userName: "MatoiDev", previewMessage: "Hi! How are you?", time: "15:18", haveSeen: false, image: Image("default")),
//        ChatCell(userName: "Kerob", previewMessage: "We schould meet today.", time: "11:28", haveSeen: false, image: Image("CPL\(Int.random(in: 1...64))")),
//        ChatCell(userName: "Loise", previewMessage: "We schould meet today.", time: "\(Int.random(in: 10..<24)):\(Int.random(in: 10..<60))", haveSeen: Bool.random(), image: Image("CPL\(Int.random(in: 1...64))")),
//        ChatCell(userName: "Max", previewMessage: "Hi!", time: "\(Int.random(in: 10..<24)):\(Int.random(in: 10..<60))", haveSeen: Bool.random(), image: Image("CPL\(Int.random(in: 1...64))")),
//        ChatCell(userName: "Meni Motti", previewMessage: "Thanks!", time: "\(Int.random(in: 10..<24)):\(Int.random(in: 10..<60))", haveSeen: Bool.random(), image: Image("CPL\(Int.random(in: 1...64))")),
//        ChatCell(userName: "Candy", previewMessage: "How about it?", time: "\(Int.random(in: 10..<24)):\(Int.random(in: 10..<60))", haveSeen: Bool.random(), image: Image("CPL\(Int.random(in: 1...64))")),
//        ChatCell(userName: "Bob", previewMessage: "Good Job! Thanks!", time: "\(Int.random(in: 10..<24)):\(Int.random(in: 10..<60))", haveSeen: Bool.random(), image: Image("CPL\(Int.random(in: 1...64))")),
//        ChatCell(userName: "Jessy", previewMessage: "Have a luck!", time: "\(Int.random(in: 10..<24)):\(Int.random(in: 10..<60))", haveSeen: Bool.random(), image: Image("CPL\(Int.random(in: 1...64))")),
//        ChatCell(userName: "Rose", previewMessage: "Just write on SE-3378", time: "\(Int.random(in: 10..<24)):\(Int.random(in: 10..<60))", haveSeen: Bool.random(), image: Image("CPL\(Int.random(in: 1...64))")),
//        ChatCell(userName: "Kate", previewMessage: "Maybe you should just check it?", time: "\(Int.random(in: 10..<24)):\(Int.random(in: 10..<60))", haveSeen: Bool.random(), image: Image("CPL\(Int.random(in: 1...64))")),
//        ChatCell(userName: "Capitan Hook", previewMessage: "Good!", time: "\(Int.random(in: 10..<24)):\(Int.random(in: 10..<60))", haveSeen: Bool.random(), image: Image("CPL\(Int.random(in: 1...64))")),
//        ChatCell(userName: "Cody", previewMessage: "Man, watch what you are looking for! It s nervous! Dont give a fuck what this damn doing!", time: "\(Int.random(in: 10..<24)):\(Int.random(in: 10..<60))", haveSeen: Bool.random(), image: Image("CPL\(Int.random(in: 1...64))"))
//
//    ]
    
    var userID: String
    private let chatsCacher = NSCache<NSString, NSArray>()
    
    private let fsmanager : FSManager = FSManager()
    
    @State private var chatsIDs: Array<String>?
    
    init(with id: String) {
        self.userID = id
        if let ids: Array<String> = chatsCacher.object(forKey: "chats") as? Array<String> {
            self.chatsIDs = ids
        }
    }
    
    
    
    var body: some View {
        NavigationView {
            if let chats = self.chatsIDs {
                List {
//                    ForEach(0..<self.chats.count, id: \.self) { chat in
//                        NavigationLink {
//                            Chat(with: )
//                        } label: {
//                            self.chats[chat]
//                        }
//                    }
                    ForEach(chats, id: \.self) { chat in
                        NavigationLink {
                            Chat(with: chat)
                        } label: {
                            ChatCell(with: chat)
                        }
                    }

                }.listRowSeparatorTint(Color("Register2"))
                        .buttonStyle(PlainButtonStyle())
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                VStack {
                                    Text("Chats").font(.custom("RobotoMono-SemiBold", size: 20)).lineSpacing(0.1)
                                            .foregroundStyle(LinearGradient(colors: [.cyan, Color("Register2")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                }
                            }
                        }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                EditButton()
                                        .font(.custom("RobotoMono-Medium", size: 16)).lineSpacing(0.1)
                                        .foregroundColor(.cyan)
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .listStyle(.plain)
            } else {
                ProgressView()
            }

        }.task {
            if self.chatsIDs == nil {
                await self.fsmanager.getUserChats { result in
                    switch result {
                    case .success(let chats):
                        self.chatsIDs = chats
                        
                        self.chatsCacher.setObject(chats as NSArray, forKey: "chats")
                    case .failure(let failure):
                        // trigger error
                        print("Here it is")
                        print("______________ Trigger error: \(failure)")
                    }
                    
                }
            }
        }
    }
}

struct ChatsTableView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsTableView(with: "qDSsjK8T5JNRcTYtDVMXT4fYqcj1")
    }
}
