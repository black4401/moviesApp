//
//  MoviesListTableViewController.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 25.01.23.
//

import UIKit
import CoreData

class MoviesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
 
    
    private var urlManager = URLManager()
    private var apiCaller = APICaller()
    private var dataManager = CoreDataManager()
    private var isLoading = false
    
    private var dataSource: [MovieModel]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Home"
        
        tableView.reloadData()
        
        tableView.delegate = self
        tableView.dataSource = self
        dataManager.delegate = self
        
        apiCaller.getTrendingMovies(page: apiCaller.pageNumber) { [weak self] movie in
            self?.dataSource = movie
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell),
           let detailsVC = segue.destination as? ShowDetailsVCViewController {
            detailsVC.title = dataSource?[indexPath.row].title
            detailsVC.configure(text: dataSource?[indexPath.row].overview)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetails", sender: tableView.cellForRow(at: indexPath))
    }
    
    func loadMovies() {
        apiCaller.getTrendingMovies(page: apiCaller.pageNumber) { [weak self] movies in
            self?.dataSource?.append(contentsOf: movies)
            print("HEREEEEE\(movies)")
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData() //TODO: fix
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        
        guard let movie = dataSource?[indexPath.row] else {
            return cell
        }
        cell.movieModel = movie
        
        guard let posterPath = movie.posterPath else {
            return cell }
        let currentURL = apiCaller.fetchImageURL(posterPath: posterPath)
        cell.loadImage(from: currentURL) { success in
            
        }
        updateStarButton(for: cell)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let count = dataSource?.count else { return }
        if indexPath.row == count - 10 {
            fetchNewMovies()
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
}

extension MoviesTableViewController {
    
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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let cellMovieTitle = (tableView.cellForRow(at: indexPath) as! MovieTableViewCell).movieModel?.title
        
        if dataManager.isMovieAlreadySaved(with: cellMovieTitle!) {
            let movie = fetchedResultsController.object(at: indexPath)
            let removeFavoriteAction = UIContextualAction(style: .destructive, title: "") { [weak self] (action, view, completion) in
                self?.dataManager.deleteFavourite(movie: movie)
                self?.updateStarButton(for: tableView.cellForRow(at: indexPath) as! MovieTableViewCell)
                completion(true)
            }
            removeFavoriteAction.image = UIImage(systemName: "star")
            removeFavoriteAction.backgroundColor = .systemRed
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
            return UISwipeActionsConfiguration(actions: [removeFavoriteAction])
        }
        let favouriteAction = UIContextualAction(style: .normal, title: "") { [weak self] (action, view, completion) in
            let image = self?.getLoadedImageFromCell(indexPath: indexPath)
            self?.dataManager.saveFavourite(movieToSave: (self?.dataSource?[indexPath.row])!, image: image)
            self?.updateStarButton(for: tableView.cellForRow(at: indexPath) as! MovieTableViewCell)
            completion(true)
        }
        
        favouriteAction.image = UIImage(systemName: "star")
        favouriteAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [favouriteAction])
    }
}

extension MoviesTableViewController {
    
    private func fetchNewMovies() {
        
        guard !isLoading else { return }
        isLoading = true
        
        tableView.tableFooterView = createSpinnerFooter()
        
        apiCaller.getTrendingMovies(page: apiCaller.pageNumber) { [weak self] movies in
            self?.dataSource?.append(contentsOf: movies)
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.isLoading = false
            }
        }
    }
    private func createSpinnerFooter() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100)
        spinner.startAnimating()
        
        return spinner
    }
}


extension MoviesTableViewController {
    
    private func getLoadedImageFromCell(indexPath: IndexPath) -> UIImage? {
        guard let cell = tableView.cellForRow(at: indexPath) as? MovieTableViewCell else {
            return UIImage(systemName: "questionmark")
        }
        return cell.getImage()
    }
}

extension MoviesTableViewController {
    
    func updateStarButton(for cell: MovieTableViewCell) {
        if dataManager.isMovieAlreadySaved(with: cell.movieModel!.title) {
            cell.starButton?.isHidden = false
        } else {
            cell.starButton?.isHidden = true
        }
    }
}



