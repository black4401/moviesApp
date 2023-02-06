//
//  TableViewCell.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 29.01.23.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var movieImageView: MovieImageView?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var dateLabel: UILabel?
    @IBOutlet private weak var ratingLabel: UILabel?
    
    @IBOutlet weak var starButton: UIButton?
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var movieModel: MovieModel? {
        didSet {
            titleLabel?.text = (movieModel!.title)
            dateLabel?.text = (movieModel!.releaseDate)
            ratingLabel?.text = "  \(String(format: "%.1f", (self.movieModel!.voteAverage)))"
            movieImageView?.image = movieModel?.image
        }
    }
    
    func loadImage(from url: URL, completion: @escaping (Bool) -> Void) {
        movieImageView?.loadImage(from: url) { isSuccessful in
            completion(isSuccessful)
        }
    }
    
    func getImage() -> UIImage? {
        if let image = movieImageView?.image {
            return image
        }
       return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        movieImageView?.image = nil
    }
}
