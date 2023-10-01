//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 01/10/2023.
//

import Foundation


public protocol FeedImageDataStore {
    
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
