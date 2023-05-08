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
    
    init() {
        Cachy.isOnlyInMemory = true
    }
    
    func get(forKey key: String) -> UIImage? {
        if let image: UIImage = Cachy.shared.get(forKey: key) {
            return image
        }
        return nil
    }
    
    func set(forKey key: String, image: UIImage) {
        let imageObject = CachyObject(value: image as UIImage, key: key)
        Cachy.shared.add(object: imageObject)
    }
}

extension ImageCache {
    private static var imageCache = ImageCache()
    static func getImageCache() -> ImageCache {
        return imageCache
    }
}
