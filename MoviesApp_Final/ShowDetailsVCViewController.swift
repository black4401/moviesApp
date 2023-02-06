//
//  ShowDetailsVCViewController.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 1.02.23.
//

import UIKit

class ShowDetailsVCViewController: UIViewController {

    private var textContent: String?
    
    var image:UIImage?
    
    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if textLabel != nil {
            textLabel.text = textContent
        }
    }
    
    func configure(text: String?) {
        self.textContent = text
    }

}
