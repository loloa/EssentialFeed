//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 18/09/2023.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    
    private var cancellable: Cancellable?
    private let feedLoader: () -> FeedLoader.Publisher
    var presenter: FeedPresenter?
    
    init(feedLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedrefresh() {
        
        presenter?.didStartLoadingFeed()
 
        cancellable = feedLoader().sink { [weak self] completion in
            
            switch completion {
                
            case .finished: break
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
            
        } receiveValue: { [weak self] feed in
            self?.presenter?.didFinishLoadingFeed(with: feed)
        }
        
//
//        feedLoader.load { [weak self] result in
//            switch result {
//            case let .success(feed):
//                self?.presenter?.didFinishLoadingFeed(with: feed)
//            case let .failure(error):
//                self?.presenter?.didFinishLoadingFeed(with: error)
//            }
//        }
    }
}

