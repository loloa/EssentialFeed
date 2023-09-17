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
    
   var delegate: FeedRefreshViewControllerDelegate?
 
   @IBOutlet private var view: UIRefreshControl?
 
   @IBAction func refresh() {
        delegate?.didRequestFeedrefresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        }else {
            view?.endRefreshing()
        }
    }
    
}
