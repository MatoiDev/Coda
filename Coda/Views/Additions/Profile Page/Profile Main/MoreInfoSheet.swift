//
//  MoreInfoSheet.swift
//  Coda
//
//  Created by Matoi on 19.11.2022.
//

import SwiftUI

struct MoreInfoSheet: View {
    
    @AppStorage("UserBio") var userBio : String = ""
    
    var body: some View {
        ZStack {
            Color("AdditionBackground").ignoresSafeArea()
            VStack {
                
                Text("Information")
                Divider()
                HStack {
                    Image(systemName: "c.circle")
                        .foregroundColor(.secondary)
                        .font(.custom("RobotoMono-Bold", size: 15))
                    Text(self.userBio)
                       Spacer()
                    
                }
                .font(.custom("RobotoMono-SemiBold", size: 13))
                
            }.frame(maxHeight: .infinity, alignment: .top)
                .padding(24)
                .foregroundColor(.primary)
                .font(.custom("RobotoMono-Bold", size: 20))
                
        }
        
        
        
    }
}

struct MoreInfoSheet_Previews: PreviewProvider {
    static var previews: some View {
        MoreInfoSheet()
    }
}
