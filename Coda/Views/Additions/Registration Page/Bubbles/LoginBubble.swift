//
//  LoginBubble.swift
//  Coda
//
//  Created by Matoi on 26.10.2022.
//

import SwiftUI

struct LoginBubble: View {
    var body: some View {
        Button {
            print("logged in!")
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.purple)
                Text("Login")
                    .font(.largeTitle)
                    .foregroundColor(.primary)
            }
            
        }
        .frame(width: 200, height: 50, alignment: .center)

    }
}

struct LoginBubble_Previews: PreviewProvider {
    static var previews: some View {
        LoginBubble()
    }
}
