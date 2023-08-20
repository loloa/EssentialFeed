//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 17/08/2023.
//

import Foundation
  
public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    public init(store: FeedStore, currentDate: @escaping () -> Date){
        self.store = store
        self.currentDate = currentDate
    }
 
    public func save(_ feed: [FeedImage], comletion: @escaping (SaveResult) -> Void ) {
        store.deleteCachedFeed {[weak self] error in
            
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                comletion(cacheDeletionError)
            } else {
                cache(feed, with: comletion)
            }
         }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { error in
            if let error {
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        self.store.insert(feed.toLocal(), timestamp: self.currentDate()) {[weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

private extension Array where Element == FeedImage {
    
    func toLocal() -> [LocalFeedImage] {
        
        return map{ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}
