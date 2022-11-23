//
//  ContinueBubble.swift
//  Coda
//
//  Created by Matoi on 15.11.2022.
//

import SwiftUI

struct ContinueBubble: View {
    
    @AppStorage("ShowPV") var showPV: Bool = false
    
    var completion: () -> Void
    
    var body: some View {
        Button {
            self.completion()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(.ultraThickMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 15).strokeBorder(LinearGradient(colors: [Color("Register2").opacity(0.7), .cyan], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                    }
                if self.showPV {
                    ProgressView()
                } else {
                    Text("Continue")
                        .font(.custom("RobotoMono-Medium", size: 20))
                        .foregroundColor(.primary)
                }
                
            }
            
        }
        .frame(width: 200, height: 50, alignment: .center)
    }
}

//struct ContinueBubble_Previews: PreviewProvider {
//    static var previews: some View {
//        ContinueBubble()
//    }
//}
