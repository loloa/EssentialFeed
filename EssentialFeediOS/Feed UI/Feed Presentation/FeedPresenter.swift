//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 14/09/2023.
//

import EssentialFeed

/*
 In MVP Model is only data, no behavior, no dependecies as in MVVM
 */
struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}
protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}
 
final class FeedPresenter {
 
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
 
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
     
    @objc func loadFeed() {
        
        loadingView?.display(FeedLoadingViewModel(isLoading: true))
        feedLoader.load(completion: {[weak self] result in
            
            if let feed = (try? result.get()) {
                self?.feedView?.display(FeedViewModel(feed: feed))
            }
            self?.loadingView?.display(FeedLoadingViewModel(isLoading: false))
        })
    }
}
