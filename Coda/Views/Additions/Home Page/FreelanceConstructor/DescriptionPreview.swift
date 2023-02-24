//
//  DescriptionPreview.swift
//  Coda
//
//  Created by Matoi on 05.02.2023.
//

import SwiftUI

struct DescriptionPreview: View {
    
    let text: String
    @Environment(\.dismiss) private var dissmiss
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                
                // MARK: - Dismiss Button
                
                Button {
                    self.dissmiss.callAsFunction()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.primary)
                }
                Spacer()
            }
            // MARK: - Text
            ScrollView(showsIndicators: false) {
                Text("")
                Text(LocalizedStringKey(self.text))
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            
            .overlay(alignment: .top, content: {
                LinearGradient(colors: [.init(red: 0.11, green: 0.11, blue: 0.12), .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 15)
            })
        }
        .background(Color(red: 0.11, green: 0.11, blue: 0.12))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.all)
    }
}

struct DescriptionPreview_Previews: PreviewProvider {
    static var previews: some View {
        DescriptionPreview(text: "Some type here...")
    }
}
