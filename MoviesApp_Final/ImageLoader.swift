//
//  ImageLoader.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 27.01.23.
//

import UIKit

class ImageLoader {
    private var imageCache = NSCache<NSURL, UIImage>()
    
    func loadImageAsync(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: url as NSURL) {
            completion(cachedImage)
        } else {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                    self.imageCache.setObject(image, forKey: url as NSURL)
                    DispatchQueue.main.async {
                        completion(image)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(UIImage(systemName: "questionmark"))
                    }
                }
            }
        }
    }
}
