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
 
    public init(store: FeedStore, currentDate: @escaping () -> Date){
        self.store = store
        self.currentDate = currentDate
    }
    
}
 
extension LocalFeedLoader {
    
    public typealias SaveResult = Error?
    
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
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        self.store.insert(feed.toLocal(), timestamp: self.currentDate()) {[weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed{ _ in }
                
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()) == false:
                self.store.deleteCachedFeed{ _ in }
            case .success:
                break
            }
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve {[weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                
                completion(.failure(error))
                
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))
                
            case .success:
                completion(.success([]))
                
            }
            
        }
    }
}

   
 
private extension Array where Element == FeedImage {
    
    func toLocal() -> [LocalFeedImage] {
        
        return map{ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}

private extension Array where Element == LocalFeedImage {
    
    func toModels() -> [FeedImage] {
        
        return map{ FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}
