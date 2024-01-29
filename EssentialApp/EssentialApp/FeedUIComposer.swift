//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 12/09/2023.
//


import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine
 
public final class FeedUIComposer {
    
    private init(){}
    
    private typealias Adapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
    public static func feedComposedWith(feedLoader: @escaping () -> AnyPublisher<Paginated<FeedImage>, Error>,
                                        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
                                        selection: @escaping (FeedImage) -> Void = {_ in}) -> ListViewController {
        
        let presentationAdapter = Adapter(
                    loader: { feedLoader().dispatchOnMainQueue() })

        
 
        let feedController = makeFeedViewController(
            title: FeedPresenter.title)
        
        feedController.onRefresh =  presentationAdapter.loadResource
       
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader:  { imageLoader($0).dispatchOnMainQueue()},
                selection: selection),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: {$0})
        
        return feedController
    }
    
    private static func makeFeedViewController(title: String) -> ListViewController {
        
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
}
 
 

 
