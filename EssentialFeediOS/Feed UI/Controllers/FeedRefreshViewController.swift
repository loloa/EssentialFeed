//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 12/09/2023.
//

import UIKit
import EssentialFeed


final class FeedRefreshViewController: NSObject {
    
    private var feedLoader: FeedLoader?
    var onRefresh: (([FeedImage]) -> Void)?
    
    private(set) lazy var view: UIRefreshControl = {
        
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    init(feedLoader: FeedLoader? = nil) {
        self.feedLoader = feedLoader
    }
    
    @objc func refresh() {
        
        view.beginRefreshing()
        feedLoader?.load(completion: {[weak self] result in
            
            if let feed = (try? result.get()) {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        })
    }
}
