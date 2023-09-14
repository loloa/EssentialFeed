//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 12/09/2023.
//

import UIKit
 

final class FeedRefreshViewController: NSObject, FeedLoadingView {
 
 
    private let feedPresenter: FeedPresenter
 
    private(set) lazy var view: UIRefreshControl = loadView()
    
    init(feedPresenter: FeedPresenter) {
        self.feedPresenter = feedPresenter
     }
    
    @objc func refresh() {
         feedPresenter.loadFeed()
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
