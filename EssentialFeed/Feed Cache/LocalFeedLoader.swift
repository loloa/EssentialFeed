//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 17/08/2023.
//

import Foundation
 
public protocol FeedStore{
    typealias DeletionCompletion = ((Error?) -> Void)
    typealias InsertionCompletion = ((Error?) -> Void)
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}



public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date){
        self.store = store
        self.currentDate = currentDate
    }
 
    public func save(_ items: [FeedItem], comletion: @escaping (Error?) -> Void ) {
        store.deleteCachedFeed {[weak self] error in
            
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                comletion(cacheDeletionError)
            } else {
                cache(items, with: comletion)
            }
         }
    }
    
    private func cache(_ items: [FeedItem], with completion: @escaping (Error?) -> Void) {
        self.store.insert(items, timestamp: self.currentDate()) {[weak self] error in
            guard let self = self else { return }
            completion(error)
        }
    }
}
