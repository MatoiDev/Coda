//
//  ImageCache.swift
//  Coda
//
//  Created by Matoi on 12.11.2022.
//


import SwiftUI
import Foundation
import Cachy // To store image on Disk

class ImageCache {
    var cache = NSCache<NSString, UIImage>()
    
    func get(forKey key: String) -> UIImage? {
        if let image: UIImage = Cachy.shared.get(forKey: key) {
            return image
        }
        return nil
        
//        return cache.object(forKey: NSString(string: key))
    }
    
    func set(forKey key: String, image: UIImage) {
        let imageObject = CachyObject(value: image as UIImage, key: key)
        Cachy.shared.add(object: imageObject)
//        cache.setObject(image, forKey: NSString(string: key))
    }
}

extension ImageCache {
    private static var imageCache = ImageCache()
    static func getImageCache() -> ImageCache {
        return imageCache
    }
}
