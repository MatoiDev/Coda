//
//  UsernameBubble.swift
//  Coda
//
//  Created by Matoi on 15.11.2022.
//

import SwiftUI

struct DataEditorInputBubble: View {
    
    @EnvironmentObject var authState: AuthenticationState
    
    var placeholder: String
    
    @Binding var text : String
    @Binding var editHandler : Bool
    
    @FocusState private var isTFEditing : Bool
    
    init(withPlaceholder: String, editable text: Binding<String>, handler: Binding<Bool>) {
        self.placeholder = withPlaceholder
        self._text = text
        self._editHandler = handler
    }
    
    var body: some View {
        VStack {
            TextField(placeholder, text: self.$text)
                .textContentType(.emailAddress)
                .keyboardType(.default)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .focused($isTFEditing)
                .onChange(of: isTFEditing) { isFocused in
                    if self.text.isEmpty {
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


//struct UsernameBubble_Previews: PreviewProvider {
//    static var previews: some View {
//        UsernameBubble()
//    }
//}
