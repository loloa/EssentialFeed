//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 18/09/2023.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    
    private var cancellable: Cancellable?
    private let loader: () -> AnyPublisher<Resource, Error>
    var presenter: LoadResourcePresenter<Resource, View>?
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        
        presenter?.didStartLoading()
        
        cancellable = loader().sink { [weak self] completion in
            
            switch completion {
                
            case .finished: break
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
            
        } receiveValue: { [weak self] resource in
            self?.presenter?.didFinishLoading(with: resource)
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

extension LoadResourcePresentationAdapter: FeedViewControllerDelegate {
    
    func didRequestFeedrefresh() {
        loadResource()
    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    
    func didRequestImage() {
         loadResource()
    }

    func didCancelImageRequest() {
        cancellable?.cancel()
    }
   
}
