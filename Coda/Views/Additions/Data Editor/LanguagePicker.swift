//
//  LanguagePicker.swift
//  Coda
//
//  Created by Matoi on 16.11.2022.
//

import SwiftUI

struct LanguagePicker: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    @Binding
    var language: PLanguages
    
    var body: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
           ]
        ScrollView {
            LazyVGrid(columns: columns, content: {
                ForEach(PLanguages.allCases, id: \.self) { lang in
                    Button {
                        self.language = lang
                        dismiss.callAsFunction()
                    } label: {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(.black)
                            .frame(height: 100)
                            .overlay {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(LinearGradient(colors: [Color("Register2"), .cyan], startPoint: .topLeading, endPoint: .bottomTrailing), style: .init(lineWidth: 2))
                                    Text(lang.rawValue)
                                        .foregroundColor(.white)
                                        .font(.custom("RobotoMono-SemiBold", size: 20))
                                }
                                
                            }
                    }

                    
                }
            }).padding(20)
        }
    }
}

struct LanguagePicker_Previews: PreviewProvider {
    static var previews: some View {
        LanguagePicker(language: .constant(.common))
    }
}
