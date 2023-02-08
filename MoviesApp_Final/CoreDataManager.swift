//
//  CoreDataManager.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 2.02.23.
//

import Foundation
import CoreData
import UIKit

enum CoreDataManagerError: Error {
    case alreadySaved
    
    var description: String {
        switch self {
            case .alreadySaved:
                return "This Movie is already in Favorites"
        }
    }
}
protocol CoreDataManagerDelegate: AnyObject {
    func handleSuccessfulSave()
    func handleUnsuccessfulSave(title: String, error: Error)
}

class CoreDataManager {
    
    weak var delegate: CoreDataManagerDelegate?
    
    var persistentContainer = CoreDataStorage.shared.persistentContainer
    
    func isMovieAlreadySaved(with title: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        fetchRequest.predicate = NSPredicate(format: "title = %@", title)
        
        var entitiesCount = 0
        
        do {
            entitiesCount = try persistentContainer.viewContext.count(for: fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return entitiesCount > 0
    }
    
    func saveFavourite(movieToSave: MovieModel, image: UIImage?) {
        let context = persistentContainer.viewContext
        
        guard !isMovieAlreadySaved(with: movieToSave.title) else {
            delegate?.handleUnsuccessfulSave(title: movieToSave.title, error: CoreDataManagerError.alreadySaved)
            return
        }
        let movie = Movie(context: context)
        movie.title = movieToSave.title
        movie.overview = movieToSave.overview
        movie.voteAverage = movieToSave.voteAverage
        movie.releaseDate = movieToSave.releaseDate
        movie.storedImage = image?.pngData()
        
        do {
            try context.save()
            delegate?.handleSuccessfulSave()
        } catch {
            
            delegate?.handleUnsuccessfulSave(title: movieToSave.title, error: error)
        }
    }
    
    func deleteFavourite(movie: Movie) {
        let context = persistentContainer.viewContext
        context.delete(movie)
        do {
            try context.save()
            delegate?.handleSuccessfulSave()
        } catch {
            delegate?.handleUnsuccessfulSave(title: movie.title!, error: CoreDataManagerError.alreadySaved)
        }
    }
    
    func deleteFavorite(with title: String) {
        guard let object = getObjectBy(title: title) else {
            return
        }
        deleteFavourite(movie: object)
    }
    
    func getObjectBy(title: String) -> Movie? {
        
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        fetchRequest.predicate = NSPredicate(format: "title = %@", title)
        
        var movies: [Movie]?
        
        do {
             movies = try persistentContainer.viewContext.fetch(request)
            
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return movies?.first(where: {$0.title == title}) ?? nil
    }
}
