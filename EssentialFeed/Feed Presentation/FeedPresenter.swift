//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 24/09/2023.
//
 
 
public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}
 
public final class FeedPresenter {
    
   
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Title for the feed screen")
    }
    
//    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
//        FeedViewModel(feed: feed)
//    }
}
