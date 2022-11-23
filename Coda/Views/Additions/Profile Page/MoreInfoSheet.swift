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
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal, 8)
                    .foregroundColor(.primary)
                    .font(.custom("RobotoMono-Bold", size: 20))
                Divider()
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                Text(self.userBio)
            }
                
        }
        
        
        
    }
}

struct MoreInfoSheet_Previews: PreviewProvider {
    static var previews: some View {
        MoreInfoSheet()
    }
}
