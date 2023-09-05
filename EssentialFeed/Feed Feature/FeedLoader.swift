//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 12/08/2023.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>  

public protocol FeedLoader {
  
    func load(completion: @escaping(LoadFeedResult) -> Void)
}
