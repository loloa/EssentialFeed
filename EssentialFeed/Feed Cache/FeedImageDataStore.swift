//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 01/10/2023.
//

import Foundation


public protocol FeedImageDataStore {
 
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL)throws -> Data?
 }

 
