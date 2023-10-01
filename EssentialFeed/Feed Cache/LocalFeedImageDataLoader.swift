//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 01/10/2023.
//

import Foundation


public final class LocalFeedImageDataLoader: FeedImageDataLoader {
 
    private let store: FeedImageDataStore
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    public enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    private class Task: FeedImageDataLoaderTask {
        
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
 
        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func cancel() {
            preventFutureCompletions()
             
        }
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        func preventFutureCompletions() {
            completion = nil
        }
     }
   
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        
        let task = Task(completion: completion)
        
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            task.complete( with: result
                .mapError { _ in Error.failed }
                .flatMap { data in
                    data.map { .success($0) }  ??  .failure( Error.notFound ) })
          }
        return task
    }
}
