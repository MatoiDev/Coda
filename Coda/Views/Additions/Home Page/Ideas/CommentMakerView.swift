//
//  CommentMakerView.swift
//  Coda
//
//  Created by Matoi on 10.04.2023.
//

import SwiftUI

struct CommentMakerView: View {
    @Binding var messageText: String
    @State private var alertTrigger: Bool = false
    var body: some View {
        ZStack(alignment: .top) {
//
            if self.messageText.isEmpty {
                Text("Add a comment")
           
                    .font(.custom("Helvetica", size: 24))
                    .padding(.all)

            }
            
            TextEditor(text: self.$messageText)
//                .foregroundColor(.clear)
                .font(.custom("Helvetica", size: 24))
                .padding(.all)
                .background(Color.clear)
                
            
        }
       
        .frame(maxWidth: .infinity, maxHeight: .infinity)
       
        .background(Color("AdditionBackground"))
        .backgroundBlur(radius: 25, opaque: true)
        .clipShape(RoundedRectangle(cornerRadius: 44))
        .overlay(content: {
            Divider()
                .blendMode(.overlay)
                .background(Color("AdditionBackground"))
                .frame(maxHeight: .infinity, alignment: .top)
                .clipShape(RoundedRectangle(cornerRadius: 44))
        })
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.secondary).opacity(0.3)
                .frame(width: 48, height: 5)
                .frame(height: 20)
                .frame(maxHeight: .infinity, alignment: .top)
        }
        
    }
}

struct CommentMakerView_Previews: PreviewProvider {
    static var previews: some View {
        CommentMakerView(messageText: .constant(""))
    }
}
