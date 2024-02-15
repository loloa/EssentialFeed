//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by אליסה לשין on 05/10/2023.
//

import EssentialFeed

public final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
 
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
       
        let task = decoratee.loadImageData(from: url) {  [weak self] result in
 
            completion( result.map{ data in
                self?.cache.saveIgnoringResult(data: data, for: url)
                return data
            })
        }
         return task
      }
}

private extension FeedImageDataCache {
    
    func saveIgnoringResult(data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}
