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
    func handleSuccessfulRemoveFromFavorite()
}

class CoreDataManager {
    
    weak var delegate: CoreDataManagerDelegate?
    
    var persistentContainer = CoreDataStorage.shared.persistentContainer
    
    // MARK: - Public Methods
    
    func isMovieAlreadySaved(with id: Int) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        fetchRequest.predicate = NSPredicate(format: "id = %d", Int32(id))
        
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
        
        guard !isMovieAlreadySaved(with: movieToSave.id) else {
            delegate?.handleUnsuccessfulSave(title: movieToSave.title, error: CoreDataManagerError.alreadySaved)
            return
        }
        let movie = Movie(context: context)
        movie.id = Int32(movieToSave.id)
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
    
    func deleteFavorite(with id: Int) {
        guard let object = getObjectBy(id: id) else {
            return
        }
        deleteFavourite(movie: object)
    }
}

private extension CoreDataManager {
    func getObjectBy(id: Int) -> Movie? {
        
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        fetchRequest.predicate = NSPredicate(format: "id = %d", id)
        
        var movies: [Movie]?
        
        do {
             movies = try persistentContainer.viewContext.fetch(request)
            
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return movies?.first(where: {$0.id == id}) ?? nil
    }
    
    func deleteFavourite(movie: Movie) {
        let context = persistentContainer.viewContext
        context.delete(movie)
        do {
            try context.save()
            delegate?.handleSuccessfulRemoveFromFavorite()
        } catch {
            delegate?.handleUnsuccessfulSave(title: movie.title!, error: CoreDataManagerError.alreadySaved)
        }
    }
}
