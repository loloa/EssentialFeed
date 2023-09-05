//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 12/08/2023.
//

import Foundation

public protocol FeedLoader {
  
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping(Result) -> Void)
}
