//
//  MovieTitle.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 27.01.23.
//

import Foundation
import UIKit

struct MovieModel: Equatable {
    let id: Int
    let releaseDate, title, overview: String
    let posterPath: String?
    let voteAverage: Double
    var image: UIImage?

    init(_ movie: MovieDTO) {
        self.id = movie.id
        self.posterPath = movie.posterPath
        self.releaseDate = movie.releaseDate
        self.title = movie.title
        self.overview = movie.overview
        self.voteAverage = movie.voteAverage
    }
    
    init(_ movie: Movie) {
        self.id = Int(movie.id)
        self.releaseDate = movie.releaseDate!
        self.title = movie.title!
        self.overview = movie.overview!
        self.voteAverage = movie.voteAverage
        self.image = movie.storedImage?.image
        self.posterPath = nil
    }
}
