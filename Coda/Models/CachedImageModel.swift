//
//  CachedImageModel.swift
//  Coda
//
//  Created by Matoi on 12.11.2022.
//

import SwiftUI
import FirebaseStorage

class CachedImageModel: ObservableObject {
    
    @Published var image: UIImage?
    
    var imageCache = ImageCache.getImageCache()
    var urlString: String?
    
    init(urlString: String?) {
        self.urlString = urlString
        loadImage()
    }
    
    init(withProject project: UOProject) {
        self.urlString = project.imageURL ?? "https://firebasestorage.googleapis.com/v0/b/com-erast-coda.appspot.com/o/DefaultImage%2Fdefault.png?alt=media&token=d344473d-190a-44f5-9ae9-3a60f7121c70"
        loadImage()
    }
    
    // MARK: - Do with chache
    
    func update(withURL url: String) {
        self.urlString = url
        loadImage()
    }
    
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
        print(self.urlString)
        guard let url = self.urlString, url != "" else {
            return
        }

        if url.split(separator: ":")[0] == "https" {
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
}

