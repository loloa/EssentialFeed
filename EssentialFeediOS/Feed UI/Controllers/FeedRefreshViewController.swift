//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 12/09/2023.
//

import UIKit
 

final class FeedRefreshViewController: NSObject, FeedLoadingView {
 
 
    private let loadFeed: () -> Void
     
 
    private(set) lazy var view: UIRefreshControl = loadView()
    
    init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
     }
    
    @objc func refresh() {
         loadFeed()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        }else {
            view.endRefreshing()
        }
    }
    
    
    
     
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
     
}
