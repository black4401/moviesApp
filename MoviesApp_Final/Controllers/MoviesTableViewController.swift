//
//  MoviesListTableViewController.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 25.01.23.
//

import UIKit
import CoreData

class MoviesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
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
        
        tableView.delegate = self
        tableView.dataSource = self
        dataManager.delegate = self
        
        
        apiCaller.getTrendingMovies(page: apiCaller.pageNumber) { [weak self] movies in
            self?.dataSource = movies
        }
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
        performSegue(withIdentifier: SegueConstants.showDetail, sender: tableView.cellForRow(at: indexPath))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifierConstants.mainCell, for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        
        guard let movie = dataSource?[indexPath.row] else {
            return cell
        }
        cell.movieModel = movie
        
        guard let posterPath = movie.posterPath else {
            return cell }
        let currentURL = apiCaller.fetchImageURL(posterPath: posterPath)
        cell.loadImage(from: currentURL)
        
        updateStarButton(for: cell)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let count = dataSource?.count else { return }
        if indexPath.row == count - MenuTableViewConstants.maxNumberOfCellsOnScreen {
            fetchNewMovies()
            loadMovies()
        }
    }
    
    func loadMovies() {
        apiCaller.getTrendingMovies(page: apiCaller.pageNumber) { [weak self] movies in
            self?.dataSource?.append(contentsOf: movies)
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension MoviesTableViewController {

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let cell = tableView.cellForRow(at: indexPath) as! MovieTableViewCell
        let title = cell.movieModel!.title
        
        if dataManager.isMovieAlreadySaved(with: title){
            let deleteAction = UIContextualAction(style: .destructive, title: "") { [weak self] (action, view, completion) in
                self?.dataManager.deleteFavorite(with: title)
                self!.updateStarButton(for: tableView.cellForRow(at: indexPath) as! MovieTableViewCell)
                completion(true)
            }

            deleteAction.image = UIImage(systemName: "star")

            return UISwipeActionsConfiguration(actions: [deleteAction])
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

private extension MoviesTableViewController {
    
    func fetchNewMovies() {
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
    
    func createSpinnerFooter() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100)
        spinner.startAnimating()
        
        return spinner
    }
    
    func getLoadedImageFromCell(indexPath: IndexPath) -> UIImage? {
        guard let cell = tableView.cellForRow(at: indexPath) as? MovieTableViewCell else {
            return UIImage(systemName: "questionmark")
        }
        return cell.getImage()
    }
    
    func updateStarButton(for cell: MovieTableViewCell) {
        if dataManager.isMovieAlreadySaved(with: cell.movieModel!.title) {
            cell.starButton?.isHidden = false
        } else {
            cell.starButton?.isHidden = true
        }
    }
}

enum MenuTableViewConstants {
    static let maxNumberOfCellsOnScreen = 10
}




