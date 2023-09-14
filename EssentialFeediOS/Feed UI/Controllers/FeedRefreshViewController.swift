//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 12/09/2023.
//

import UIKit
 
protocol FeedRefreshViewControllerDelegate {
    
    func didRequestFeedrefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
 /*
     private let loadFeed: () -> Void
    init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
     }
  @objc func refresh() {
      loadFeed()
  }
    */
    
    private let delegate: FeedRefreshViewControllerDelegate
 
    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }

    private(set) lazy var view: UIRefreshControl = loadView()
 
    @objc func refresh() {
        delegate.didRequestFeedrefresh()
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
