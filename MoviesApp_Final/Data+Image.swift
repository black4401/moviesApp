//
//  Data+Image.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 29.01.23.
//

import UIKit

extension Data {
    var image: UIImage? { UIImage(data: self) }
}
