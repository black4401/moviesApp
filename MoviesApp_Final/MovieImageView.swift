//
//  MovieImageView.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 29.01.23.
//

import UIKit

class MovieImageView: UIImageView {

    private var url: URL!
    private var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override init(image: UIImage?) {
        super.init(image: image)
        addSubview(activityIndicator)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(activityIndicator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicator.center = center
    }
    
    func loadImage(from url: URL, completion: @escaping (Bool) -> Void) {
        image = nil
        self.url = url
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            ImageLoader.fetchImage(from: url) { loadedImage in
                guard let loadedImage else {
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                    }
                    return
                }
                guard self?.url == url else { return }
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.alpha = 0
                    self?.image = loadedImage
                    UIView.animate(withDuration: 0.5, delay: 0) {
                        self?.alpha = 1
                    }
                    completion(true)
                }
            }
        }
    }
}
