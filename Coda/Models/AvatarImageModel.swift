//
//  AvatarImageModel.swift
//  Coda
//
//  Created by Matoi on 12.11.2022.
//

import SwiftUI
import FirebaseStorage

class AvatarImageModel: ObservableObject {
    
    @Published var image: UIImage?
    
    var imageCache = ImageCache.getImageCache()
    var urlString: String?
    
    init(urlString: String?) {
        self.urlString = urlString
        loadImage()
    }
    
    // MARK: - Do with chache
    
    func loadImageFromCache() -> Bool {
        guard let urlString = urlString else {
            return false
        }
        
        guard let cacheImage = imageCache.get(forKey: urlString) else {
            return false
        }
        
        image = cacheImage
        return true
    }
    
    // MARK: - Native loading
    func loadImage() {
        if loadImageFromCache() {
            return
        }
        loadImageFromUrl()
    }
    
    func loadImageFromUrl() {
        guard let url = self.urlString else {
            return
        }
        let ref = Storage.storage().reference(forURL: url)
        let memory : Int64 = Int64(1048576)
        ref.getData(maxSize: memory) { data, err in
            guard let image = data else {
                print("error with getting an image")
                return
            }
            DispatchQueue.main.async {
                guard let img = UIImage(data: image) else {
                    print("cannot parse a data")
                    return
                }
                self.imageCache.set(forKey: url, image: img)
                self.image = img
            }
        }
    }
}

