//
//  DataBubble.swift
//  Coda
//
//  Created by Matoi on 25.10.2022.
//

import SwiftUI

struct DataBubble: View {
    var type: BubbleType
    @EnvironmentObject var user : UserInfo
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .frame(width: UIScreen.main.bounds.width * 0.85, height: 50)
            .foregroundColor(.gray)
            .overlay {
                TextField(self.type == .password ? "Enter password" : "Enter Login", text: self.type == .password ? self.$user.password : self.$user.login)
            }
        
    }
}

struct DataBubble_Previews: PreviewProvider {
    static var previews: some View {
        DataBubble(type: .login)
    }
}
