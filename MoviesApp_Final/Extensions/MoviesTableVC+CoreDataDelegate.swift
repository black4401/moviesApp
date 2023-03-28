//
//  MoviesTableVC+CoreDataDelegate.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 2.02.23.
//

import Foundation
import UIKit

extension MoviesTableViewController: CoreDataManagerDelegate {
    
    func handleSuccessfulSave() {
        let alert = UIAlertController(title: nil, message: "Movie added to favorites", preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true)
        }
    }

    func handleUnsuccessfulSave(title: String, error: Error) {
        let alert = UIAlertController(title: nil, message: "\(title) is already in favorites.", preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true)
        }
    }
    
    func handleSuccessfulRemoveFromFavorite() {
        let alert = UIAlertController(title: nil, message: "Movie removed from favorites", preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true)
        }
    }
}
