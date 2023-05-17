//
//  FavoritesTabViewController.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 25.01.23.
//

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController {
    
    // MARK: - Properties
    
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
    
    // MARK: - Lifecycle
    
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
    
    // MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell),
           let detailsVC = segue.destination as? ShowDetailsVCViewController {
            let movie = fetchedResultsController.object(at: indexPath)
            detailsVC.configure(text: movie.overview, image: movie.storedImage?.image)
            detailsVC.title = movie.title
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SegueConstants.showDetail, sender: tableView.cellForRow(at: indexPath))
    }
}

// MARK: - TableView Delegate Methods

extension FavoritesTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifierConstants.mainCell,
                                                 for: indexPath) as! MovieTableViewCell
        
        let movie = fetchedResultsController.object(at: indexPath)
        let movieModel = MovieModel(movie)
        
        cell.movieModel = movieModel
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movie = fetchedResultsController.object(at: indexPath)
            dataManager.deleteFavorite(with: Int(movie.id))
        }
    }
}

// MARK: - FetchedResultsController Delegate

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

extension FavoritesTableViewController: FilterMenuDelegate {
    
    private func createSortButton() -> UIButton {
        let sortButton = UIButton()
        sortButton.showsMenuAsPrimaryAction = true
        sortButton.menu = filterMenu.fulleMenu
        sortButton.addAction(sortButtonAction(), for: .menuActionTriggered)
        sortButton.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        return sortButton
    }
    
    private func sortButtonAction() -> UIAction {
        return UIAction(title: "") { _ in
        }
    }
    
    func didDismissMenu() {
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
        selectedOptions.1 = type.state
    }
}


