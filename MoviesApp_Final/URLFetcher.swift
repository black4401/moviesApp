//
//  URLFetcher.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 27.01.23.
//

import Foundation

//class URLManager {
//    private let apikey = "ef97a8d015181b94d509935f0343688b"
//    func fetchMoviesURL(page: Int) -> URL {
//        var components = URLComponents()
//        components.scheme = "https"
//        components.host = "api.themoviedb.org"
//        components.path = "/3/movie/popular"
//        components.queryItems = [
//            URLQueryItem(name: "api_key", value: apikey),
//            URLQueryItem(name: "language", value: "en-US"),
//            URLQueryItem(name: "page", value: String(page))
//        ]
//        return components.url!
//    }
//    
//    func fetchImageURL(posterPath: String) -> URL {
//        var components = URLComponents()
//        components.scheme = "https"
//        components.host = "image.tmdb.org"
//        components.path = "/t/p/w200\(posterPath)"
//        return components.url!
//    }
//}
