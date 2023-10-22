//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 24/09/2023.
//
 
 
public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}
 
public protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}
 
public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public final class FeedPresenter {
    
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Title for the feed screen")
    }
    
    private var feedLoaderError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR", tableName: "Shared", bundle: Bundle(for: FeedPresenter.self), comment: "Error explanation")
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
