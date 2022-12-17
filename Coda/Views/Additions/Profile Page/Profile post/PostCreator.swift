//
//  PostCreator.swift
//  Coda
//
//  Created by Matoi on 10.12.2022.
//

import SwiftUI

struct PostCreator: View {
    
    @AppStorage("UserID") private var userID : String = ""
    
    @Environment(\.dismiss) private var dismiss
    @State private var postEnabled: Bool = false
    
    @State private var showingAlert = false
    @State private var alertLog = ""
    
    @State private var showProgressView: Bool = false
    
    @State private var postBody: String = ""
    @State private var postImage: UIImage?
    
    //    @Binding var posts: [String]
    @AppStorage("UserPosts") var userPosts : [String] = []
    
    private var fsmanager: FSManager = FSManager()
    
    var body: some View {
        VStack {
            HStack {
                // MARK: - Close editor button
                Button {
                    self.dismiss.callAsFunction()
                } label: {
                    Image(systemName: "xmark.circle")
                }.font(.custom("RobotoMono-Light", size: 22))
                
                Spacer()
                // MARK: - Title
                Text("New Post")
                Spacer()
                // MARK: - Create post button
                if self.showProgressView {
                    ProgressView()
                } else {
                    Button {
                        self.showProgressView = true
                        self.fsmanager.createPost(owner: self.userID, text: self.postBody, image: self.postImage) { result in
                            switch result {
                            case .success(let postID):
                                self.fsmanager.add(post: postID, to: self.userID) { result in
                                    switch result {
                                    case .success(_):
                                        self.showProgressView = false
                                        self.userPosts.append(postID)
                                        self.fsmanager.getUsersData(withID: self.userID)
                                        
                                        self.dismiss.callAsFunction()
                                    case .failure(let failure):
                                        self.showProgressView = false
                                        self.alertLog = failure.localizedDescription
                                        self.showingAlert.toggle()
                                    }
                                }
                            case .failure(let failure):
                                self.showProgressView = false
                                self.alertLog = failure.localizedDescription
                                self.showingAlert.toggle()
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                    }.font(.custom("RobotoMono-SemiBold", size: 27))
                        .foregroundColor(self.postBody.isEmpty ? .secondary : .primary)
                        .disabled(self.postBody.isEmpty)
                }
            }
            .font(.custom("RobotoMono-Bold", size: 23))
            .foregroundColor(.primary)
            .padding(.top, 16)
            .padding(.horizontal, 16)
            Divider()
            
            // MARK: - Text Editor
            PostEditor(postBody:  self.$postBody, postImage: self.$postImage)
            Spacer()
        }
        .alert(self.alertLog, isPresented: self.$showingAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

struct PostCreator_Previews: PreviewProvider {
    static var previews: some View {
        PostCreator()
    }
}
