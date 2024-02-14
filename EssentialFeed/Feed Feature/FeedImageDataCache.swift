//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 05/10/2023.
//


public protocol FeedImageDataCache {
     func save(_ data: Data, for url: URL) throws
}
