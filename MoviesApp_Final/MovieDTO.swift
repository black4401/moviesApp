//
//  MovieDTO.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 29.01.23.
//

import Foundation


struct Page: Codable {
    let movies: [MovieDTO]
    
    enum CodingKeys: String, CodingKey {
        case movies = "results"
    }
}

struct MovieDTO: Codable {
    let id: Int
    let posterPath, releaseDate, title, overview: String
    let voteAverage: Double

    enum CodingKeys: String, CodingKey {
        case id
        case releaseDate = "release_date"
        case title
        case overview
        case voteAverage = "vote_average"
        case posterPath = "poster_path"
    }
}
