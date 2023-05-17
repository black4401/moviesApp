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
    @IBOutlet private weak var infoButton: UIButton!
    @IBOutlet private weak var favoriteButton: UIButton!
    
    var movieModel: MovieModel? {
        didSet {
            titleLabel?.text = (movieModel!.title)
            dateLabel?.text = formatDate(dateText: movieModel!.releaseDate)
            ratingLabel?.text = "\(String(format: "%.1f", (self.movieModel!.voteAverage)))"
            movieImageView?.image = movieModel?.image
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        movieImageView?.image = nil
    }
    
    private func formatDate(dateText: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let date = Date(from: dateText, format: "yyyy-MM-dd")
        return dateFormatter.string(from: date!)
    }
    
    func loadImage(from url: URL, completion: ((Bool) -> Void)? = nil) {
        movieImageView?.loadImage(from: url) { isSuccessful in
            completion?(isSuccessful)
        }
    }
    
    func getImage() -> UIImage {
        (movieImageView?.image)!
    }
}
