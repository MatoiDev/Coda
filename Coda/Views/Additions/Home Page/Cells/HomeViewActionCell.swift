//
//  HomeViewActionCell.swift
//  Coda
//
//  Created by Matoi on 30.01.2023.
//

import SwiftUI

struct HomeViewActionCell<Content: View>: View {
    
    let title: String
    let image: String
    @ViewBuilder let destination: Content
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(image)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(10)
                    .padding(.trailing, 6)
                Text(title)
                    .font(.custom("RobotoMono-SemiBold", size: 17))
            }
            
            .frame(maxWidth: .infinity, alignment: .leading)
        }.padding(.leading, 12)
            .padding(.trailing)
            .padding(.vertical, 12)
    }
}
