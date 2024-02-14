//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 01/10/2023.
//

import Foundation


public final class LocalFeedImageDataLoader {
    
    private let store: FeedImageDataStore
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache
{
    public typealias SaveResult = FeedImageDataCache.Result
    
    public enum SaveError: Error {
        case failed
    }
    
    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
 
        completion(SaveResult {
            try store.insert(data, for: url)
        }.mapError({ _ in
            SaveError.failed
        }))       
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    
    public typealias LoadResult = FeedImageDataLoader.Result
    
    public enum LoadError: Error {
        case failed
        case notFound
    }
    
    private class LoadImageDataTask: FeedImageDataLoaderTask {
        
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
    
    
    
    public func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        
        let task = LoadImageDataTask(completion: completion)
        task.complete( 
            with: Swift.Result {
            try store.retrieve(dataForURL: url)
        }
            .mapError { _ in LoadError.failed }
            .flatMap { data in
                data.map { .success($0) }  ??  .failure( LoadError.notFound ) })
        
        
        return task
    }
}
