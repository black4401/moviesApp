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
//        let alert = UIAlertController(title: nil, message: "Movie added to favorites", preferredStyle: .alert)
//        present(alert, animated: true)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.dismiss(animated: true)
//        }
    }

    func handleUnsuccessfulSave(title: String) {
//        let alert = UIAlertController(title: nil, message: "\(title) is already in favorites.", preferredStyle: .alert)
//        present(alert, animated: true)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.dismiss(animated: true)
//        }
    }
}
