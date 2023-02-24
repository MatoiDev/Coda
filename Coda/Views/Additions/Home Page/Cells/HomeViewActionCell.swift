//
//  HomeViewActionCell.swift
//  Coda
//
//  Created by Matoi on 30.01.2023.
//

import SwiftUI

struct HomeViewActionCell<Content: View>: View {
    
    @State var isActive: Bool = false
    
    let title: String
    let image: String
    @ViewBuilder let destination: (_ active: Binding<Bool>) ->  Content
    
    var body: some View {
        NavigationLink(isActive: self.$isActive) {
            destination($isActive)
        } label: {
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
        }

    
        .isDetailLink(false)
        .padding(.leading, 12)
            .padding(.trailing)
            .padding(.vertical, 12)
            .onChange(of: self.isActive) { newValue in
                print("Change the new value, need to close the root view: \(newValue)")
            }
    }
}
