//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by אליסה לשין on 04/10/2023.
//

import EssentialFeed

 class FeedLoaderStub {
    
    private let result: Swift.Result<[FeedImage], Error>
    
    init(result: Swift.Result<[FeedImage], Error>) {
        self.result = result
    }
    func load(completion: @escaping (Swift.Result<[FeedImage], Error>) -> Void) {
        completion(result)
    }
}
