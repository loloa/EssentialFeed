//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by אליסה לשין on 18/12/2023.
//

//
//  CommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 12/09/2023.
//


import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

public final class CommentsUIComposer {
    
    private init(){}
    
    private typealias Adapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
    
    public static func commentsComposedWith(commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) -> ListViewController {
        
        let presentationAdapter = Adapter(
                    loader: { commentsLoader().dispatchOnMainQueue() })

        
 
        let feedController = makeFeedViewController(
            title: ImageCommentsPresenter.title)
        
        feedController.onRefresh =  presentationAdapter.loadResource
       
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader:  { _ in Empty<Data, Error>().eraseToAnyPublisher() }),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: /*FeedPresenter.map*/ FeedViewModel.init)
        
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
 
 

 

