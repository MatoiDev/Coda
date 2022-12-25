//
//  CellImageView.swift
//  Coda
//
//  Created by Matoi on 25.12.2022.
//

import SwiftUI

struct CellImageView: View {
    @ObservedObject var urlImageModel: CachedImageModel
    
    init(urlString: String?) {
        urlImageModel = CachedImageModel(urlString: urlString)
    }
    
    func updateImage(url: String) {
        self.urlImageModel.update(withURL: url)
    }
    
    var body: some View {
        if let image = urlImageModel.image {
            Image(uiImage: image)
                .resizable()
                .clipShape(Circle())
        } else {
            ProgressView()
        }

    }
    static var defaultImage = UIImage(named: "default")
}
