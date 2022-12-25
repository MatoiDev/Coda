//
//  Chat.swift
//  Coda
//
//  Created by Matoi on 24.12.2022.
//

import SwiftUI

struct Chat: View {

    var id: String

    init(with id: String) {
        self.id = id
    }

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct Chat_Previews: PreviewProvider {
    static var previews: some View {
        Chat(with: "dfsfsdgbsd")
    }
}
