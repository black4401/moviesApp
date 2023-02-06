//
//  APICaller.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 27.01.23.
//

import Foundation

//struct Constants {
//    static let API_KEY = "b9154cb727a3792889b9d7c73195411f"
//    static let baseURL = "https://api.themoviedb.org"
//
//}

class APICaller {
    
    let apiKey = "b9154cb727a3792889b9d7c73195411f"
    let baseURL = "https://api.themoviedb.org"
    
    func fetchMoviesURL(page: Int) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        components.path = "/3/movie/popular"
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: String(page))
        ]
        return components.url!
    }
    
    func fetchImageURL(posterPath: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "image.tmdb.org"
        components.path = "/t/p/w200\(posterPath)"
        return components.url!
    }
    
    var pageNumber = 1
    
    func getTrendingMovies(page: Int, success: @escaping ([MovieModel]) -> Void) {
        
        pageNumber += 1
        let session = URLSession(configuration: .default)
        session.fetchData(for: fetchMoviesURL(page: page)) {(result: Result<Page, Error>) in
            
            switch result {
                case .success(let page):
                    let movies: [MovieModel] = page.movies.map { movie in
                        MovieModel(movie)
                    }
                    success(movies)
                case .failure(let error):
                    print("Fetch data not successful!")
            }
            
        }
    }
}

