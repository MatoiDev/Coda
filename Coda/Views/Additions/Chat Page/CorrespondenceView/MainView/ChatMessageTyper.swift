//
//  ChatMessageTyper.swift
//  Coda
//
//  Created by Matoi on 29.12.2022.
//

import SwiftUI

struct ChatMessageTyper: View {
    
    @Binding var messageText: String
    
    var body: some View {
        TextField("Write a message...", text: self.$messageText)
                      .textFieldStyle(.roundedBorder)
                      .font(.custom("RobotoMono-SemiBold", size: 15))
                      .frame(maxWidth: .infinity)
                      .clipShape(RoundedRectangle(cornerRadius: UIScreen.main.bounds.height))
                      .multilineTextAlignment(TextAlignment.center)
                      .overlay {
                          RoundedRectangle(cornerRadius: UIScreen.main.bounds.height).strokeBorder(lineWidth: 1.2).foregroundColor(.secondary)
                      }
    }
}

//struct ChatMessageTyper_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatMessageTyper()
//    }
//}
