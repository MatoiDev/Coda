//
//  SecuredDataBubble.swift
//  Coda
//
//  Created by Matoi on 26.10.2022.
//

import SwiftUI

struct SecuredDataBubble: View {
    
    @Binding private var text: String
    @Binding private var didEndEdit : Bool
    
    @FocusState private var isTFEditing : Bool
    
    @State private var isSecured: Bool = true
    
    private var placeHolder: String
    
    init(withPlaceHolder placeHolder: String, text: Binding<String>, editHandler: Binding<Bool>) {
        self.placeHolder = placeHolder
        self._text = text
        self._didEndEdit = editHandler
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isSecured {
                    SecureField(placeHolder, text: $text)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused($isTFEditing)
                        .onChange(of: isTFEditing) { isFocused in
                            
                            if !isFocused {
                                didEndEdit = true
                                print("yeah")
                            }
                            
                        }
                } else {
                    TextField(placeHolder, text: $text)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused($isTFEditing)
                        .onChange(of: isTFEditing) { isFocused in
                            
                            if !isFocused {
                                didEndEdit = true
                                print("yeah")
                            }
                            
                        }
                }
            }.padding(.trailing, 32)
            
            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                    .accentColor(.gray)
            }
        }
    }
}

//struct SecuredDataBubble_Previews: PreviewProvider {
//    static var previews: some View {
//        SecuredDataBubble()
//    }
//}
