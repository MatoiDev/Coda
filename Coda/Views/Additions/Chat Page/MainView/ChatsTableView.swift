//
//  ChatView.swift
//  Coda
//
//  Created by Matoi on 30.10.2022.
//


import SwiftUI
import Cachy


struct ChatsTableView: View {

    private var userID: String
    private let fsmanager : FSManager = FSManager()
    
    
    @State private var chatsIDs: Array<String>?
    @State private var multiSelection = Set<String>()
    @State private var chatName: String?
    
    // For hiding TabBar
    @State var hideTabBar: Bool = false
    
    
    
    init(with id: String) {
        self.userID = id
        if let ids: Array<String> = Cachy.shared.get(forKey: "chats") {
            print("Use cached value")
            self.chatsIDs = ids
        }
    }
    
    
    
    var body: some View {
        NavigationView {
            if let chats = self.chatsIDs {
                List(selection: self.$multiSelection) {
                    ForEach(0..<chats.count, id: \.self) { ind in
                        NavigationLink {
                            Chat(with: chats[ind], tabbarObserver: self.$hideTabBar)
                        } label: {
                            ChatCell(with: chats[ind])
                        }
                    }

                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                            .robotoMono(.medium, 16, color: .cyan)
                            .lineSpacing(0.1)
                            
                    }
                }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    print("Add chat button has pressed!")
                                } label: {
                                    Image(systemName: "square.and.pencil")
                                        .foregroundColor(Color("Register2"))
                                }

                            }
                        }
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                VStack {
                                    Text("Chats")
                                        .robotoMono(.semibold, 20)
                                        .lineSpacing(0.1)
//                                        .foregroundStyle(LinearGradient(colors: [.cyan, Color("Register2")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                }
                            }
                        }
                        
                        .navigationBarHidden(false)
                        .navigationBarTitleDisplayMode(.inline)
                        .listStyle(.plain)
            } else {
                ProgressView()
                    .navigationBarTitleDisplayMode(.inline)
                    .listStyle(.plain)
                    .navigationBarHidden(false)
            }

        }
        .publishOnTabBarAppearence(self.hideTabBar)
        .background(Color.black)
        .background(.ultraThinMaterial)
        .task {
            if self.chatsIDs == nil {
                await self.fsmanager.getUserChats { result in
                    switch result {
                    case .success(let chats):
                        self.chatsIDs = chats
                        let object = CachyObject(value: chats as NSArray, key: "chats")
                        Cachy.shared.add(object: object)
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
