//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by אליסה לשין on 04/10/2023.
//


import EssentialFeed

public final class FeedLoaderCacheDecorator: FeedLoader {
    
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            
            
            completion(result.map { feed in
                self?.cache.saveIgnoringResult(feed)
                return feed
            })
            
            //            if let feed = try? result.get(){
            //                self?.cache.save(feed, comletion: {_ in })
            //            }
            // completion(result)
            
        }
    }
}

private extension FeedCache {
    
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed, comletion: { _ in })
    }
}
