//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 14/09/2023.
//

import Foundation
import EssentialFeed

struct FeedErrorViewModel {
    
    let message: String?
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

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
 
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Title for the feed screen")
    }
    
    private var feedLoaderError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Error explanation")
    }
    
    init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
     
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoaderError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
 }



// 4_decoupling_closure
/*
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
*/
