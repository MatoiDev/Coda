//
//  AvatarImageView.swift
//  Coda
//
//  Created by Matoi on 12.11.2022.
//

import SwiftUI
import Kingfisher

struct AvatarImageView: View {
    @ObservedObject var urlImageModel: CachedImageModel
    let onPostImage: Bool
    @State private var urlString: String?
    @Binding var bottomSheetTranslationProrated: CGFloat
    
    init(urlString: String?, onPost condition: Bool = false, translation: Binding<CGFloat>) {
        urlImageModel = CachedImageModel(urlString: urlString)
        self.onPostImage = condition
        self.urlString = urlString
        _bottomSheetTranslationProrated = translation
    }
    
    func updateImage(url: String) {
        self.urlString = url
        self.urlImageModel.update(withURL: url)
    }
    
    var body: some View {
        if let urlString: String = self.urlString {
            if !self.onPostImage {
//                                Image(uiImage: urlImageModel.image ?? AvatarImageView.defaultImage!)
                KFImage
                    .url(URL(string: urlString))

                    .placeholder({ progress in
                        CircularProgressView(progress: progress.fractionCompleted)
                            .fixedSize()
                    })
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
//                KFImage
//                    .url(URL(string: urlString))
//
//                    .placeholder({ progress in
//                        CircularProgressView(progress: progress.fractionCompleted)
//                            .fixedSize()
//                    })
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

        
    }
    static var defaultImage = UIImage(named: "default")
}



struct AvatarImageView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarImageView(urlString: "", translation: .constant(1))
    }
}
