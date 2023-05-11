//
//  Date+Init.swift
//  MoviesApp_Final
//
//  Created by Alexander Angelov on 10.05.23.
//

import Foundation

extension Date {
    init?(from text: String, format: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        if let date = formatter.date(from: text) {
            self.init(timeInterval: 0, since: date)
        } else {
            return nil
        }
    }
}
