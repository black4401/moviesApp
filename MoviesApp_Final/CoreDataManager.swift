//
//  CoreDataManager.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 2.02.23.
//

import Foundation
import CoreData
import UIKit

protocol CoreDataManagerDelegate: AnyObject {
    func handleSuccessfulSave()
    func handleUnsuccessfulSave(title: String)
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
            delegate?.handleUnsuccessfulSave(title: movieToSave.title)
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
            delegate?.handleUnsuccessfulSave(title: movieToSave.title)
        }
    }
    
    func deleteFavourite(movie: Movie) {
        let context = persistentContainer.viewContext
        context.delete(movie)
        do {
            try context.save()
            delegate?.handleSuccessfulSave()
        } catch {
            delegate?.handleUnsuccessfulSave(title: movie.title!)
        }
    }
}
