//
//  ChooseLanguageButton.swift
//  Coda
//
//  Created by Matoi on 16.11.2022.
//

import SwiftUI

struct ChooseLanguageButton: View {
    
    @Binding
    var language: PLanguages
    
    @State
    var showLanguagePicker : Bool = false
    
    var body: some View {
        Button {
            self.showLanguagePicker.toggle()
        } label: {
            
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.ultraThickMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 15).strokeBorder(LinearGradient(colors: [Color("Register2").opacity(0.7), .cyan], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                }
                .overlay {
                    HStack {
                        Text(language.rawValue)
                            .robotoMono(.medium, 20)

                            .multilineTextAlignment(.leading)
                        Spacer()
                    }.padding(.horizontal, 20)
                }
            
        }
        .frame(width: UIScreen.main.bounds.width - 50, height: 50, alignment: .center)
        .fullScreenCover(isPresented: self.$showLanguagePicker) {
            LanguagePicker(language: self.$language)
        }
    }
}

struct ChooseLanguageButton_Previews: PreviewProvider {
    static var previews: some View {
        ChooseLanguageButton(language: .constant(.swift))
    }
}
