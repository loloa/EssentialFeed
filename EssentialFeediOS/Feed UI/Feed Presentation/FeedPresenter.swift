//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 14/09/2023.
//

import EssentialFeed

protocol FeedLoadingView {
    func display(isLoading: Bool)
}
protocol FeedView {
     func display(feed:[FeedImage])
}
 
final class FeedPresenter {
 
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
 
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
     
    @objc func loadFeed() {
        
        loadingView?.display(isLoading: true)
        feedLoader.load(completion: {[weak self] result in
            
            if let feed = (try? result.get()) {
                self?.feedView?.display(feed: feed)
            }
            self?.loadingView?.display(isLoading: false)
        })
    }
}
