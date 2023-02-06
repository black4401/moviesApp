//
//  ImageLoader.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 27.01.23.
//

import UIKit

struct ImageLoader {
    static func fetchImage(from: URL, completion: @escaping (UIImage?)->()) {
        let dataTask = URLSession.shared.dataTask(with: from) { (data, _, _) in
            if let data = data {
                // Create Image and Update Image View
                guard let image = UIImage(data: data) else { return }
                    completion(image)
            } else {
                completion(UIImage(systemName: "questionmark"))
            }
        }
        dataTask.resume()
    }
}
