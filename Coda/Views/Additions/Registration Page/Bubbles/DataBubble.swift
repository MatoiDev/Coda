//
//  DataBubble.swift
//  Coda
//
//  Created by Matoi on 25.10.2022.
//

import SwiftUI

struct DataBubble: View {
    
    @Binding var text : String
    @Binding var editHandler : Bool
    
    @FocusState private var isTFEditing : Bool
    
    var body: some View {
        TextField("Email", text: self.$text)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .focused($isTFEditing)
            .onChange(of: isTFEditing) { isFocused in
                if !isFocused {
                    editHandler = true
                    print("yeah")
                }
            }
    }
}
