//
//  ExploreHeaderViewCell.swift
//  Coda
//
//  Created by Matoi on 31.01.2023.
//

import SwiftUI

struct ExploreHeaderViewCell: View {
    
    let title: String
    let image: String?
    let selected: Bool
    
    var body: some View {
        HStack {
            Text(LocalizedStringKey(self.title))
                .padding(.leading, 4)
                .padding(.vertical, 2)
                
            if let imageName: String = self.image {
                if imageName == "lightbulb", selected {
                    Image(systemName: "lightbulb.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 15)
                        .padding(.trailing, 4)
                } else {
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 15)
                        .padding(.trailing, 4)
                }
                
                    
            }
        }
        .foregroundColor(.white)
        .font(.custom("RobotoMono-SemiBold", size: 15))
        .padding(4)
        .background(
            self.selected ? LinearGradient(colors: [Color("Register2").opacity(0.45), .cyan.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                LinearGradient(colors: [Color("AdditionDarkBackground")], startPoint: .leading, endPoint: .trailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(LinearGradient(colors: [Color("Register2"), .cyan], startPoint: .topLeading, endPoint: .bottom), style: .init(lineWidth: 1))
        }
        .frame(height: 35)
       
    }
}
