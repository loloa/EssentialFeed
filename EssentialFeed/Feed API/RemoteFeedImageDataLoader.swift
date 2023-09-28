//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 28/09/2023.
//

import Foundation

public final class RemoteFeedImageDataLoader {
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    private class HTTPTaskWrapper: FeedImageDataLoaderTask {
        
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        var wrapped: HTTPClientTask?
        
        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func cancel() {
            preventFutureCompletions()
            wrapped?.cancel()
        }
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        func preventFutureCompletions() {
            completion = nil
        }
    }
    
    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
       let taskWrapper = HTTPTaskWrapper(completion: completion)
        
        taskWrapper.wrapped = client.get(from: url, completion: { [weak self] result in
            
            guard self != nil else { return }
            switch result {
            case let .failure(error):
                taskWrapper.complete(with: .failure(error))
                
            case let .success((data, response)):
               
                if response.statusCode == 200, data.isEmpty == false {
                    taskWrapper.complete(with: .success(data))
                } else {
                    taskWrapper.complete(with: .failure(Error.invalidData))
                 }
            }
        })
        return taskWrapper
    }
}
