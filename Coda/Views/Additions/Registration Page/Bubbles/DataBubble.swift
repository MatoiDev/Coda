//
//  DataBubble.swift
//  Coda
//
//  Created by Matoi on 25.10.2022.
//

import SwiftUI

struct DataBubble: View {
    
    @EnvironmentObject var authState: AuthenticationState
    
    @Binding var text : String
    @Binding var editHandler : Bool
    
    @FocusState private var isTFEditing : Bool
    
    var body: some View {
        VStack {
            TextField("Email", text: self.$text)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .focused($isTFEditing)
                .onChange(of: isTFEditing) { isFocused in
                    if self.text == "" {
                        editHandler = false
                    }
                    else if !isFocused {
                        self.authState.errorHandler = ""
                        editHandler = true
                        print("yeah")
                    }
                }
            Divider()
        }.frame(width: UIScreen.main.bounds.width - 50)
    }
}
