//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 05/10/2023.
//


public protocol FeedImageDataCache {
    
     typealias Result = Swift.Result<Void, Error>
     func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
