//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 13/09/2023.
//

//platform agnostic reusable component (no ,atter MacOS, iOS(UIkit), watch)
//import UIKit
 
import EssentialFeed

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
 
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
    
     
    @objc func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load(completion: {[weak self] result in
            
            if let feed = (try? result.get()) {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChange?(false)
        })
    }
}
