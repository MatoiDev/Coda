//
//  MessageBubble.swift
//  Coda
//
//  Created by Matoi on 29.12.2022.
//

import SwiftUI
import AVKit
import AVFoundation
import Cachy
import FirebaseStorage

struct MessageBubble<Content>: View where Content: View {
    
    @AppStorage("LoginUserID") var loginUserID: String = ""
    
    private let fsmanager: FSManager = FSManager()
    
    @State private var CCImageView : ChatCachedImageView?
    
    
    
    let messageID: String
    
    @State var direction: ChatBubbleShape.Direction?
    @State var time: String?
    @State var messageBody: String?
    @State var wasEdited: Bool?
    @State var checked: Bool?
    @State var content: (() -> Content)?
    @State var chatID: String?
    @State var imageID: String?
    
    // Массив IDs пользователей, которые прочитали сообщение
    @State var whoHasRead: Array<String>?
    // Данный параметр - ширина нижнего овала сообщения, зависит от его свойств, от кого, было ли изменено, прочитал или нет и т.д.
    @State var messageInfoBubbleWidth: CGFloat
    
    // Показывает шторку редактирования сообщения при изменении
    @Binding var editTrigger: Bool
    // Передаёт родителю сообщение, которое нужно изменить
    @Binding var messageToEdit: String
    // Передаёт родителю ID сообщения, которое нужно изменить
    @Binding var editingMessageID: String
    // Передаёт родителю ID изображения (если оно есть) в сообщении, которое нужно изменить
    @Binding var imageOptionalID: String
    // Передаёт родителю само изображение, есть оно есть или пустое UIImage("")
    @Binding var messageImage: UIImage
    
    @State private var imageToSave: UIImage?
    
    // MARK: - First Initializer
    init(id: String, direction: ChatBubbleShape.Direction, time: String, checked: Bool = false, wasEdited: Bool = false, editTrigger: Binding<Bool>, message: Binding<String>, editMessageID: Binding<String>, imageOptionalID: Binding<String>, uiMessageImage: Binding<UIImage>, @ViewBuilder content: @escaping () -> Content) {
        self.messageID = id
        self.content = content
        self.time = time
        self.checked = checked
        self.wasEdited = wasEdited
        self.direction = direction
        self.messageInfoBubbleWidth = 60
        
        self._messageToEdit = message
        self._editTrigger = editTrigger
        self._editingMessageID = editMessageID
        self._imageOptionalID = imageOptionalID
        self._messageImage = uiMessageImage
    }
    
    // MARK: - Second Initializer
    init(id: String, editTrigger: Binding<Bool>, message: Binding<String>, editMessageID: Binding<String>, imageOptionalID: Binding<String>, uiMessageImage: Binding<UIImage>, @ViewBuilder content: @escaping () -> Content) {
        
        self.messageID = id
        self.messageInfoBubbleWidth = 60
        
        self._messageToEdit = message
        self._editTrigger = editTrigger
        self._editingMessageID = editMessageID
        self._imageOptionalID = imageOptionalID
        self._messageImage = uiMessageImage
    }
    
    private func tryToGetMessageImageAsync() async -> Void {
            guard let url = self.imageID, url != "" else { return }
            if url.split(separator: ":")[0] == "https" {
                let ref = Storage.storage().reference(forURL: url)
                let memory : Int64 = Int64(1048576)
                ref.getData(maxSize: memory) { data, err in
                    guard let image = data else {
                        print("error with getting an image")
                        return
                    }
                    DispatchQueue.main.async {
                        guard let img = UIImage(data: image) else {
                            print("cannot parse a data")
                            return
                        }
                        self.imageToSave = img
                    }
                }
            }
        }
    
    var body: some View {
        // Если сообщение загружено
        if let direction = self.direction, let time = self.time, let wasEdited = self.wasEdited, let checked = self.checked {
            VStack {
                HStack {
                    if direction == .right {
                        Spacer()
                            .onAppear {
                                self.messageInfoBubbleWidth = 90
                            }
                            
                    }
                    VStack(alignment: .trailing) {
                        HStack(alignment: .bottom) {
                            // MARK: - Message

                            if let messageBody = self.messageBody {
                                // MARK: - Non-cached mesasge
                                VStack {
                                    // MARK: - Message image
                                    // Если в сообщении есть изображение
                                    if let imageID = self.imageID, imageID != "" {
                                        let CCImageView : ChatCachedImageView = ChatCachedImageView(with: imageID, for: .Message)
                                        CCImageView
                                            .onAppear {
                                                self.CCImageView = CCImageView
                                            }.task {
                                                await tryToGetMessageImageAsync()
                                            }
                                            
                                        
                                        
                                    }
                                // MARK: - Message Body
                                    if messageBody != "" {
                                        HStack {
                                            Text(messageBody)
                                                .font(.custom("RobotoMono-SemiBold", size: 15))
                                                .padding(.all, 10)
                                                .padding(.leading, self.direction == .left ? 4 : 0)
                                                .foregroundColor(Color.white)
                                            if imageID != "" {
                                                Spacer()
                                            }
                                        }
                                        
                                    }
                                }
                            } else {
                                // MARK: - Cached Image
                                if let content = self.content
                                {
                                    content()
                                       
                                }
                            }
                            
                        }
                        
                    }.background(direction == .left ? Color("BubbleMessageRecievedColor") : Color("BubbleMessageSentColor"))
                        .clipShape(ChatBubbleShape(direction: direction))
                        .onAppear {
                            if direction == .left {
                                if let whoHasRead = self.whoHasRead, !whoHasRead.contains(self.loginUserID) {
                                    self.fsmanager.add(reader: self.loginUserID, toMessage: self.messageID) { res in
                                        switch res {
                                        case .success(let succes):
                                            print(succes)
                                        case .failure(let err):
                                            print("___need to trigger error: \(err)")
                                        }
                                    }
                                }
                                
                            }
                        }
                    if direction == .left {
                        Spacer()
                    }
                }
                // MARK: - Message info
                HStack {
                    if direction == .right { Spacer() }
                    HStack {
                        // MARK: - Ticks
                        if direction == .right {
                            if checked {
                                Image("tick.double")
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: 13, height: 13)
                                    .foregroundColor(Color("BubbleMessageSentColor"))
                            } else {
                                Image("tick")
                                
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: 13, height:  13)
                                    .foregroundColor(Color("BubbleMessageSentColor"))
                                
                            }
                            Text("|")
                                .foregroundColor(Color("BubbleMessageSentColor"))
                        }
                        
                        // MARK: - Time
                        Text(time)
                            .foregroundStyle(LinearGradient(colors: [Color("BubbleMessageSentColor"), .cyan], startPoint: .leading, endPoint: .trailing))
                        // MARK: - Edit status
                        if wasEdited {
                            Text("|")
                                .foregroundColor(.cyan)
                            Image(systemName: "square.and.pencil")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.cyan)
                                .onAppear {
                                    if self.direction == .left {
                                        self.messageInfoBubbleWidth = 90
                                    } else if self.direction == .right {
                                        self.messageInfoBubbleWidth = 120
                                    }
                                    
                                }
                        }
                    }
                    .padding(1)
                        .padding(.horizontal, 4)
                    .font(.custom("RobotoMono-Light", size: 11))
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30))
                        .frame(height: 15)
                        .fixedSize()
                   
                        
                    if direction == .left {Spacer() }
                }
      
            }
            // MARK: - On Message hold (Context menu)
                .contextMenu(menuItems: {
                    if direction == .right {
                        // MARK: - Edit button
                        Button {
                            print("Editing message")
                            withAnimation {
                                
                                self.editTrigger.toggle()
                                self.messageToEdit = self.messageBody!
                                self.imageOptionalID = self.imageID!
                                self.editingMessageID = self.messageID
                                
                                if let uiCCImageView = self.CCImageView?.urlImageModel.image {
                                    self.messageImage = uiCCImageView
                                }
                                
                            }
                            
                        } label: {
                            HStack {
                                Text("Edit")
                                Spacer()
                                Image(systemName: "square.and.pencil")
                            }.font(.custom("RobotoMono-SemiBold", size: 14))
                            
                        }
                    }
                    if let inputImage = self.CCImageView?.urlImageModel.image {
                        Button {
                            
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: inputImage)
                            Vibro.trigger(.success)
                        } label: {
                            HStack {
                                Text("Save photo")
                                Spacer()
                                Image(systemName: "arrow.down.circle")
                            }.font(.custom("RobotoMono-SemiBold", size: 14))

                        }
                    } else if let inputImage = self.imageToSave {
                        Button {
                            
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: inputImage)
                            Vibro.trigger(.success)
                        } label: {
                            HStack {
                                Text("Save photo")
                                Spacer()
                                Image(systemName: "arrow.down.circle")
                            }.font(.custom("RobotoMono-SemiBold", size: 14))

                        }
                    }
                    else if self.messageImage != UIImage() {
                        Button {
                            
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: self.messageImage)
                            Vibro.trigger(.success)
                        } label: {
                            HStack {
                                Text("Save photo")
                                Spacer()
                                Image(systemName: "arrow.down.circle")
                            }.font(.custom("RobotoMono-SemiBold", size: 14))

                        }
                    }
                    if let messageBody = self.messageBody, messageBody != "" {
                        Button {
                            UIPasteboard.general.string = messageBody
                        } label: {
                            HStack {
                                Text("Copy text")
                                Spacer()
                                Image(systemName: "doc.on.doc")
                            }.font(.custom("RobotoMono-SemiBold", size: 14))
                        }
                    }
                    

                   
                    
                    if direction == .right {
                        // MARK: - Delete message button
                        Divider()
                        Button(role: .destructive) {
                            self.fsmanager.remove(message: messageID, from: self.chatID!)
                        } label: {
                            HStack {
                                Text("Delete")
                                Spacer()
                                Image(systemName: "trash")
                            }.font(.custom("RobotoMono-SemiBold", size: 14))
                        }

                    }
                    
                })
            .task {
                // MARK: - Observeing for message updates
                await self.fsmanager.getMessageInfo(id: self.messageID) { result in
                    switch result {
                    case .success(let messageData):
                        let messageObject = CachyObject(value: messageData as NSDictionary, key: "messageData:\(messageID)")
                        
                        Cachy.shared.add(object: messageObject)
                        
                        let senderID: String = messageData["sender"]! as! String
                        let dayTime: String = messageData["dayTime"]! as! String
                        let body: String = messageData["body"]! as! String
                        let wasEdited = (messageData["didEdit"]! as! String) == "true"
                        let whoHasRead = messageData["whoHasRead"] as! Array<String>
                        let chatID = messageData["chatID"]! as! String
                        
                        let imageID = messageData["image"]! as! String
                        
                        self.imageID = imageID
                        
                        self.chatID = chatID
                        self.direction = senderID == self.loginUserID ? .right : .left
                        self.time = dayTime
                        self.checked = whoHasRead.count != 0
                        self.wasEdited = wasEdited
                        
                        self.messageBody = body
                        
                        
                    case .failure(let failure):
                        print("Message Bubble need to handle error")
                    }
                }
            }
        } else {
            ProgressView()
                .task {
            
                    
                        // MARK: - Task for message
                    await self.fsmanager.getMessageInfo(id: self.messageID) { result in
                            switch result {
                            case .success(let messageData):
                                let messageObject = CachyObject(value: messageData as NSDictionary, key: "messageData:\(messageID)")
                                print("messageData: \(messageData)")
                                Cachy.shared.add(object: messageObject)
                                
                                let senderID: String = messageData["sender"]! as! String
                                let dayTime: String = messageData["dayTime"]! as! String
                                let body: String = messageData["body"]! as! String
                                let wasEdited = (messageData["didEdit"]! as! String) == "true"
                                let whoHasRead = messageData["whoHasRead"] as! Array<String>
                                let chatID = messageData["chatID"]! as! String
                                let imageID = messageData["image"]! as! String
                                
                                self.imageID = imageID
                                self.chatID = chatID
                                self.direction = senderID == self.loginUserID ? .right : .left
                                self.time = dayTime
                                self.checked = whoHasRead.count != 0
                                self.wasEdited = wasEdited
                                
                                self.whoHasRead = whoHasRead
                                
                                self.messageBody = body
                    
                                
                            case .failure(let failure):
                                print("Message Bubble need to handle error")
                            }
                        }
                    await tryToGetMessageImageAsync()
                    
                }
        }
//        .padding([(direction == .left) ? .leading : .trailing, .top, .bottom], 20)
//            .padding((direction == .right) ? .leading : .trailing, 50)
        
    }
}


//struct MessageBubble_Previews: PreviewProvider {
//
//    static var previews: some View {
//        List {
//            Section {
//                MessageBubble(direction: .left, time: "10:09") {
//                    Text("Hi! How are you?")
//
//                        .font(.custom("RobotoMono-SemiBold", size: 15))
//                                            .padding(.all, 10)
//                                            .foregroundColor(Color.white)
//
//
//
//                }
//                MessageBubble(direction: .right, time: "10:09", checked: true) {
//                    Text("I'm tired and drain...")
//
//                        .font(.custom("RobotoMono-SemiBold", size: 15))
//                                            .padding(.all, 10)
//                                            .foregroundColor(Color.white)
//
//
//
//                }
//                MessageBubble(direction: .left, time: "10:09", checked: true) {
//                    Text("Know what?")
//
//                        .font(.custom("RobotoMono-SemiBold", size: 15))
//                                            .padding(.all, 10)
//                                            .foregroundColor(Color.white)
//
//
//
//                }
//                MessageBubble(direction: .right, time: "10:09", checked: true) {
//                    Text("Uhh?")
//
//                        .font(.custom("RobotoMono-SemiBold", size: 15))
//                                            .padding(.all, 10)
//                                            .foregroundColor(Color.white)
//
//
//
//                }
//                MessageBubble(direction: .left, time: "10:09") {
//                    Text("Check this out!")
//
//                        .font(.custom("RobotoMono-SemiBold", size: 15))
//                                            .padding(.all, 10)
//                                            .padding(.leading, 4)
//                                            .foregroundColor(Color.white)
//
//                }
//                MessageBubble(direction: .left, time: "10:09", wasEdited: true) {
//                    VStack (alignment: .leading){
//                        Image("CPL1")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            Text("Holy sh...")
//
//                                .font(.custom("RobotoMono-SemiBold", size: 15))
//                                                    .padding(.all, 10)
//                                                    .foregroundColor(Color.white)
//
//
//                    }
//
//
//
//
//                }
//                MessageBubble(direction: .right, time: "10:09", checked: true, wasEdited: true) {
//                    Text("Holy sh...")
//
//                        .font(.custom("RobotoMono-SemiBold", size: 15))
//                                            .padding(.all, 10)
//                                            .foregroundColor(Color.white)
//                }
//                MessageBubble(direction: .left, time: "10:09", wasEdited: true) {
//                    Text("Holy shkljkfejlkjfelrjfe...")
//
//                        .font(.custom("RobotoMono-SemiBold", size: 15))
//                                            .padding(.all, 10)
//                                            .foregroundColor(Color.white)
//                }
//
//            }
//            .listRowSeparator(.hidden)
//           .listRowBackground(Color.clear)
//
//        }.listStyle(.plain)
//            }
//}
