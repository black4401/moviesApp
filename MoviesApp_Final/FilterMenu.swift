//
//  FilterMenu.swift
//  MoviesApp
//
//  Created by Alexander Angelov on 2.02.23.
//

import Foundation
import UIKit

enum SortingOption: String, CaseIterable {
    case title
    case voteAverage
    case releaseDate
    
    var sortionOptionTitle: String {
        switch self {
        case .title:
            return "Title"
        case .voteAverage:
            return "Rating"
        case .releaseDate:
            return "Date"
        }
    }
}

enum FilterOption: CaseIterable {
    case ascending
    case descending
    
    var state: Bool {
        switch self {
        case .ascending:
            return true
        case .descending:
            return false
        }
    }
    
    var filterOptionTitle: String {
        switch self {
        case .ascending:
            return "Ascending"
        case .descending:
            return "Descending"
        }
    }
}

protocol FilterMenuDelegate: AnyObject {
    func sortingIsChosen(type: SortingOption)
    func filteringIsChosen(type: FilterOption)
}

class FilterMenu: UIMenu {
    var sortByOptionElement: UIMenuElement?
    var orderByOption: UIMenuElement?
    var fulleMenu: UIMenu?
    
    weak var delegate: FilterMenuDelegate?
    
    private func createSortingActions() -> [UIAction] {
        var sortAct: [UIAction] = []
        SortingOption.allCases.forEach { sortingOption in
            sortAct.append(UIAction(title: sortingOption.sortionOptionTitle) { _ in
                self.delegate?.sortingIsChosen(type: sortingOption)
            })
        }
        sortAct.first(where: { $0.title == SortingOption.title.sortionOptionTitle})?.state = .on
        return sortAct
    }
    
    private func createFilteringActions() -> [UIAction] {
        var filterAct: [UIAction] = []
        FilterOption.allCases.forEach { filterOption in
            filterAct.append(UIAction(title: filterOption.filterOptionTitle) { _ in
                self.delegate?.filteringIsChosen(type: filterOption)
            })
        }
        filterAct.first(where: { $0.title == FilterOption.ascending.filterOptionTitle})?.state = .on
        return filterAct
    }
    
    func configure() {
        sortByOptionElement = UIMenu(title: "", options: [.displayInline,.singleSelection], children: createSortingActions())
        orderByOption = UIMenu(title: "", options: [.displayInline,.singleSelection], children: createFilteringActions())
        guard let first = sortByOptionElement, let second = orderByOption else { return }
        fulleMenu = UIMenu(title: "Sort By", children: [first,second])
    }
}
