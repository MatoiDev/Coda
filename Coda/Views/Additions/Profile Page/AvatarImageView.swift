//
//  AvatarImageView.swift
//  Coda
//
//  Created by Matoi on 12.11.2022.
//

import SwiftUI

struct AvatarImageView: View {
    @ObservedObject var urlImageModel: AvatarImageModel
    @Binding var bottomSheetTranslationProrated: CGFloat
    
    init(urlString: String?, translation: Binding<CGFloat>) {
        urlImageModel = AvatarImageModel(urlString: urlString)
        _bottomSheetTranslationProrated = translation
    }
    
    var body: some View {
        Image(uiImage: urlImageModel.image ?? AvatarImageView.defaultImage!)
            .resizable()
            .frame(width: 150 - 50 * bottomSheetTranslationProrated, height: 150 - 50 * bottomSheetTranslationProrated)
            .clipShape(Circle())
            .offset(y: -75 * (1 - bottomSheetTranslationProrated))
            
            .overlay {
                Circle()
                    .stroke(lineWidth: 7 - 4 * bottomSheetTranslationProrated)
                    .foregroundColor(.black)
                    .offset(x: UIScreen.main.bounds.width * 0 * (1 - bottomSheetTranslationProrated), y: -75 * (1 - bottomSheetTranslationProrated))
//                    .opacity(1 - bottomSheetTranslationProrated)
            }.overlay {
                if self.urlImageModel.image == nil {
                    ProgressView()
                        .offset(x: UIScreen.main.bounds.width * 0 * (1 - bottomSheetTranslationProrated), y: -75 * (1 - bottomSheetTranslationProrated))
                }
            }.padding(self.bottomSheetTranslationProrated * 16)
    }
    static var defaultImage = UIImage(named: "default")
}



struct AvatarImageView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarImageView(urlString: "", translation: .constant(1))
    }
}
