//
//  IdeaHeaderView.swift
//  Coda
//
//  Created by Matoi on 09.04.2023.
//

import SwiftUI

struct IdeaHeaderView: View {
    
    
    
    let userID: String
    let time: String
    
    init(with userID: String, time: String = "") {
        
        self.userID = userID
        self.time = time
    }
    
    @State private var avatarURL: String? = nil
    @State private var firstName: String? = nil
    @State private var secondName: String? = nil
    @State private var username: String? = nil
    
    @State private var reputation: Int? = nil
    
    
    private let fsmanager: FSManager = FSManager()
    
    @State private var starRotationCoefficent: CGFloat = 0

    var body: some View {
        ZStack {
            Group {
                if let username = self.username {
                    HStack(alignment: .top) {
                        CachedImageView(with: self.avatarURL, for: .Default)
                            .frame(width: 32, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16).strokeBorder(Color.secondary, style: StrokeStyle.init(lineWidth: 0.2))
                            }
                            
                        VStack(alignment: .leading) {
                            Text(username)
                                .robotoMono(.bold, 13)
                            Text(self.time)
                                .robotoMono(.medium, 11, color: .secondary)
                        
                        }
                        
                        
                        Spacer()
                    }
                } else {
                    EmptyView()
                }
            }
        }

        .task {
           await self.fsmanager.getUserInfo(forID: self.userID) { res in
                switch res {
                case .success(let userData):
                    
                    self.avatarURL = (userData["avatarURL"] as! String)
                    self.firstName = (userData["name"] as! String)
                    self.secondName = (userData["surname"] as! String)
                    self.reputation = (userData["reputation"] as! Int)
                    self.username = (userData["username"] as! String)
                    
                case .failure(let failure):
                    print("IdeaHeaderView: \(failure.localizedDescription)")
                }
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 2)) {
                self.starRotationCoefficent = 360 * 2
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

    }
}

struct IdeaHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        IdeaHeaderView(with: "fsadfs")
    }
}
