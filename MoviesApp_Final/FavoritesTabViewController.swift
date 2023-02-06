//
//  FavoritesTabViewController.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 25.01.23.
//

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController, FilterMenuDelegate {
    
    private var dataManager = CoreDataManager()
    private var filterMenu = FilterMenu()
    
    private var selectedOptions: (String, Bool) = ("title", true) {
        didSet {
            reloadSorted(sort: NSSortDescriptor(key: selectedOptions.0, ascending: selectedOptions.1))
        }
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
        
        let context = dataManager.persistentContainer.viewContext
        
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        let resultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        resultsController.delegate = self
        
        do {
            try resultsController.performFetch()
        } catch {
            print("Could not perform fetch")
        }
        
        return resultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Favorites"
        
        filterMenu.delegate = self
        filterMenu.configure()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: createSortButton())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell),
           let detailsVC = segue.destination as? ShowDetailsVCViewController {
            let movie = fetchedResultsController.object(at: indexPath)
            detailsVC.configure(text: movie.overview)
            detailsVC.title = movie.title
        }
    }
}

extension FavoritesTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell",
                                                 for: indexPath) as! MovieTableViewCell
        
        // Fetch the data for the row.
        let movie = fetchedResultsController.object(at: indexPath)
        let movieModel = MovieModel(movie)
        
        // Configure the cell’s contents with data from the fetched object.
        cell.movieModel = movieModel
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movie = fetchedResultsController.object(at: indexPath)
            
            dataManager.deleteFavourite(movie: movie)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let viewDetailsAction = UIContextualAction(style: .normal, title: "") { (action, view, completion) in
            self.performSegue(withIdentifier: "showDetails", sender: tableView.cellForRow(at: indexPath))
            completion(true)
        }
        
        viewDetailsAction.image = UIImage(systemName: "arrowshape.right")
        viewDetailsAction.backgroundColor = .systemBlue
        
        let config = UISwipeActionsConfiguration(actions: [viewDetailsAction])
        
        return config
    }
}

extension FavoritesTableViewController: NSFetchedResultsControllerDelegate  {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                tableView.reloadRows(at: [indexPath!], with: .fade)
            case .move:
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            @unknown default:
                break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension FavoritesTableViewController: CoreDataManagerDelegate {
    func handleSuccessfulSave() {
//        let alert = UIAlertController(title: nil, message: "Successfully deleted.", preferredStyle: .alert)
//        present(alert, animated: true)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.dismiss(animated: true)
//        }
    }
    
    func handleUnsuccessfulSave(title: String) {
//        let alert = UIAlertController(title: nil, message: "\(title) could not be deleted.", preferredStyle: .alert)
//        present(alert, animated: true)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.dismiss(animated: true)
//        }
    }
}

extension FavoritesTableViewController {
    
    private func createSortButton() -> UIButton {
        let sortButton = UIButton()
        sortButton.showsMenuAsPrimaryAction = true
        sortButton.menu = filterMenu.fullMenu
        sortButton.addAction(sortButtonAction(), for: .menuActionTriggered)
        sortButton.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        return sortButton
    }
    
    private func sortButtonAction() -> UIAction {
        return UIAction(title: "") { _ in
        }
    }
    
    private func reloadSorted(sort: NSSortDescriptor) {
        fetchedResultsController.fetchRequest.sortDescriptors = [sort]
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Couldnt perform fetch")
        }
        tableView.reloadData()
    }
    
    func sortingIsChosen(type: SortingOption) {
        selectedOptions.0 = type.rawValue
    }
    
    func filteringIsChosen(type: FilterOption) {
        selectedOptions.1 = type.isAscending
    }
}


