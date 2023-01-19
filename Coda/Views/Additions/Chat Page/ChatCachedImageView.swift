//
//  CellImageView.swift
//  Coda
//
//  Created by Matoi on 25.12.2022.
//

import SwiftUI
import Foundation

enum ImageType {
    case Cell
    case ChatIntelocutorLogo
    case Message
    case CellMessage
}


struct ChatCachedImageView: View {
    @ObservedObject var urlImageModel: CachedImageModel
    
    var type: ImageType
    
    init(with urlString: String?, for type: ImageType) {
        self.urlImageModel = CachedImageModel(urlString: urlString)
        self.type = type
    }
    
    func updateImage(url: String) {
        self.urlImageModel.update(withURL: url)
    }
    
    
    var body: some View {
        if let image = urlImageModel.image {
            if self.type == .Message {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if self.type == .CellMessage {
                Image(uiImage: image)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .frame(width: 20, height: 20)
            }
            else {
                Image(uiImage: image)
                    .resizable()
                    .clipShape(Circle())
            }
            
        } else {
            ProgressView()
        }

    }
    static var defaultImage = UIImage(named: "default")
}
