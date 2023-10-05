//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 04/10/2023.
//

import Foundation


public protocol FeedCache {
    
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feed: [FeedImage], comletion: @escaping (Result) -> Void )
}
