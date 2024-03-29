//
//  ProfileActionCell.swift
//  Coda
//
//  Created by Matoi on 19.11.2022.
//

import SwiftUI

struct ProfileActionCell: View {
    
    let completion: () -> Void
    let text: String
    
    init(withText text: String, completion: @escaping () -> Void) {
        self.completion = completion
        self.text = text
    }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                self.completion()
            }
            
        } label: {
            ZStack {
                ScrollView {}
                    .clipShape(Rectangle())
                
                    .background(.ultraThinMaterial)
                    .clipped()
                    .frame(width: UIScreen.main.bounds.width - 30, height: 40, alignment: .center)
                    .background(Color("AdditionBackground"))
                    .overlay {
                        HStack {
                            
                            if self.text == "More information" {
                                Image(systemName: "info.circle")
        
                            } else if self.text == "Create Post" {
                                Spacer()
                                Image(systemName: "square.and.pencil")
                  
                            }
                            Text(self.text)
                            Spacer()
                        }.padding(.horizontal, 16)
                            .robotoMono(.bold, 15, color: .white)
                    }.cornerRadius(15)
            }
            
        }
    }
}

struct ProfileActionCell_Previews: PreviewProvider {
    static var previews: some View {
        ProfileActionCell(withText: "Projects") {
            print("Huui")
        }
    }
}
