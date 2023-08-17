//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 17/08/2023.
//

import Foundation

public protocol FeedStore{
    typealias DeletionCompletion = ((Error?) -> Void)
    typealias InsertionCompletion = ((Error?) -> Void)
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}


