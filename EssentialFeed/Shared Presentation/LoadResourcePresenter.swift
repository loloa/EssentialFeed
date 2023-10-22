//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 22/10/2023.
//

import Foundation

public final class LoadResourcePresenter {
    
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
 
    
    private var feedLoaderError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Error explanation")
    }
    
    public init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    //data in -> transform -> data out to the UI
    
    // Void -> transform -> sends to the UI
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    // [FeedImage] -> transform -> sends to the UI
    // [ImageComment] -> transform -> sends to the UI
    // Data -> transform -> sends to the UI
    
    //Resource -> create ResiurceViewModel -> sends to UI
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    // Eror -> transform -> sends to the UI
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoaderError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
