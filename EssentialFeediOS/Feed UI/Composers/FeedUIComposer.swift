//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 12/09/2023.
//


import UIKit
import EssentialFeed

public final class FeedUIComposer {
    
    private init(){}
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedPresenter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(feedPresenter: feedPresenter)
        let feedController = FeedViewController(refreshController: refreshController)
        
        feedPresenter.loadingView = WeakRefVrtualProxy(refreshController)
        feedPresenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)
        
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        
        return { [weak controller] feed in
            controller?.tableModel = feed.map{ model in
                
                FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init))
            }
        }
    }
}

// memory management mooved to composer, removed from presenter
/*
 A proxy implements an interface for purpose of providing access to something else
 */
private final class WeakRefVrtualProxy<T: AnyObject> {
    
    private weak var object: T?
     
    init(_ object: T) {
        self.object = object
    }
}
extension WeakRefVrtualProxy: FeedLoadingView where T: FeedLoadingView {
    
    func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
}

private final class FeedViewAdapter: FeedView {
    
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
     
    func display(feed: [EssentialFeed.FeedImage]) {
        
        controller?.tableModel = feed.map{ model in
            FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
        }
    }
 
}
