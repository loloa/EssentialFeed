//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 13/09/2023.
//


import UIKit

//platform agnostic reusable component (no ,atter MacOS, iOS(UIkit), watch)
import EssentialFeed

final class FeedViewModel {
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    
    var onChange:((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    private(set) var isLoading: Bool = false {
        didSet {  onChange?(self) }
    }
     
    @objc func loadFeed() {
        
        isLoading = true
        feedLoader.load(completion: {[weak self] result in
            
            if let feed = (try? result.get()) {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        })
    }
    
}
