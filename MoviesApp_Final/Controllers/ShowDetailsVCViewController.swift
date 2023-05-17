//
//  ShowDetailsVCViewController.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 1.02.23.
//

import UIKit

class ShowDetailsVCViewController: UIViewController {

    private var textContent: String?
    private var image: UIImage?
    private var url: URL? {
        didSet {
            loadImage(from: url!) { completion in
                if completion {
                    self.setBackgroundImage(with: self.image)
                }
            }
        }
    }
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if textView != nil {
            textView.text = textContent
            setBackgroundImage(with: image)
        }
    }
    
    func configure(text: String?, image: UIImage?) {
        self.textContent = text
        self.image = image
    }
    
    func configure(text: String?, url: URL) {
        self.textContent = text
        self.url = url
    }
    
    private func setBackgroundImage(with image: UIImage?) {
        let tabBarFrameHeight = tabBarController!.tabBar.frame.height
        let backgroundImageView = UIImageView(image: image)
        
        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.alpha = 0.3
        backgroundImageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - tabBarFrameHeight)
        
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
    }
    
    private func loadImage(from url: URL, completion: @escaping (Bool) -> Void) {
        image = nil
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            ImageLoader.fetchImage(from: url) { loadedImage in
                guard let loadedImage else {
                    completion(false)
                    return
                }
                guard self?.url == url else { return }
                DispatchQueue.main.async {
                    self?.image = loadedImage
                    completion(true)
                }
            }
        }
    }
}
