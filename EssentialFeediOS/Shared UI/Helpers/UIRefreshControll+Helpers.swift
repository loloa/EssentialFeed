//
//  UIRefreshControll+Helpers.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 29/01/2024.
//

import UIKit


extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
