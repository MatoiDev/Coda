//
//  AvatarImageView.swift
//  Coda
//
//  Created by Matoi on 12.11.2022.
//

import SwiftUI

struct AvatarImageView: View {
    @ObservedObject var urlImageModel: CachedImageModel
    let onPostImage: Bool
    @Binding var bottomSheetTranslationProrated: CGFloat
    
    init(urlString: String?, onPost condition: Bool = false, translation: Binding<CGFloat>) {
        urlImageModel = CachedImageModel(urlString: urlString)
        self.onPostImage = condition
        _bottomSheetTranslationProrated = translation
    }
    
    func updateImage(url: String) {
        self.urlImageModel.update(withURL: url)
    }
    
    var body: some View {
        if !self.onPostImage {
            Image(uiImage: urlImageModel.image ?? AvatarImageView.defaultImage!)
                .resizable()
                .frame(width: 150 - 50 * bottomSheetTranslationProrated, height: 150 - 50 * bottomSheetTranslationProrated)
                .clipShape(Circle())
                .offset(y: -75 * (1 - bottomSheetTranslationProrated))
                
                .overlay {
                    Circle()
                        .stroke(lineWidth: 7 - 4 * bottomSheetTranslationProrated)
                        .foregroundColor(.black)
                        .offset(y: -75 * (1 - bottomSheetTranslationProrated))
                }.overlay {
                    if self.urlImageModel.image == nil {
                        ProgressView()
                            .offset(y: -75 * (1 - bottomSheetTranslationProrated))
                    }
                }.padding(self.bottomSheetTranslationProrated * 16)
        } else {
            Image(uiImage: urlImageModel.image ?? AvatarImageView.defaultImage!)
                .resizable()
                .frame(width: 40, height:40)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundColor(.black)
                }.overlay {
                    if self.urlImageModel.image == nil {
                        ProgressView()
                    }
                }.padding(self.bottomSheetTranslationProrated * 16)
        }
        
    }
    static var defaultImage = UIImage(named: "default")
}



struct AvatarImageView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarImageView(urlString: "", translation: .constant(1))
    }
}
