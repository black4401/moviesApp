//
//  ShowDetailsVCViewController.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 1.02.23.
//

import UIKit

class ShowDetailsVCViewController: UIViewController {
    
    // MARK: - Properties
    
    private var textContent: String?
    private var image: UIImage?
    private var url: URL?
    private let imageLoader = ImageLoader()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .black
        
        setBackgroundImage(with: image)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if textView != nil {
            textView.text = textContent
        }
    }
    
    func configure(text: String?, image: UIImage?) {
        self.textContent = text
        self.image = image
    }
    
    func configure(text: String?, url: URL) {
        self.textContent = text
        self.url = url
        self.loadImage(from: url)
    }
    
    // MARK: - Private Methods
    
    private func setBackgroundImage(with image: UIImage?) {
        let tabBarFrameHeight = tabBarController!.tabBar.frame.height
        let backgroundImageView = UIImageView(image: image)
        
        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.alpha = 0.3
        backgroundImageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - tabBarFrameHeight)
        
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
    }
    
    private func loadImage(from url: URL?) {
        guard let url = url else {
            return
        }
        imageLoader.loadImageAsync(from: url) { [weak self] image in
            self?.image = image
            self?.setBackgroundImage(with: image)
        }
    }
}
