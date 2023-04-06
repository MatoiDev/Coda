//
//  AvatarImageView.swift
//  Coda
//
//  Created by Matoi on 12.11.2022.
//

import SwiftUI
import Kingfisher

struct AvatarImageView: View {
    let onPostImage: Bool
    let urlString: String
    @Binding var bottomSheetTranslationProrated: CGFloat
    
    init(urlString: String?, onPost condition: Bool = false, translation: Binding<CGFloat>) {
        self.urlString = urlString ?? "https://firebasestorage.googleapis.com/v0/b/com-erast-coda.appspot.com/o/DefaultImage%2F8d7e9d76ab83277382d33925fa9e4aca.png?alt=media&token=ad231de0-5ea9-46fc-aafe-62d024163492"
        self.onPostImage = condition
        _bottomSheetTranslationProrated = translation
    }
    
    var body: some View {
        
            Group {
                if !self.onPostImage {
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
                        }
                        .padding(self.bottomSheetTranslationProrated * 16)
                } else {
                    KFImage
                        .url(URL(string: urlString))

                        .placeholder({ progress in
                            CircularProgressView(progress: progress.fractionCompleted)
                                .fixedSize()
                        })
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(lineWidth: 2)
                                .foregroundColor(.black)
                        }
                        .padding(self.bottomSheetTranslationProrated * 16)
                }
            }
            .onAppear {
                print("I'll try to load: \(self.urlString)")
            }

        
    }
    static var defaultImage = UIImage(named: "default")
}



struct AvatarImageView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarImageView(urlString: "", translation: .constant(1))
    }
}
