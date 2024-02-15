//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 28/09/2023.
//

import Foundation

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
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
    
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        let taskWrapper = HTTPTaskWrapper(completion: completion)
        
        taskWrapper.wrapped = client.get(from: url, completion: { [weak self] result in
            
            guard self != nil else { return }
            
            taskWrapper.complete(with: result
                .mapError { _ in Error.connectivity}
                .flatMap{ (data, response) in
                    let isValidResponse = response.isOK && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                }
             )
            
            //            switch result {
            //            case .failure:
            //                taskWrapper.complete(with: .failure(Error.connectivity))
            //
            //            case let .success((data, response)):
            //
            //                if response.statusCode == 200, data.isEmpty == false {
            //                    taskWrapper.complete(with: .success(data))
            //                } else {
            //                    taskWrapper.complete(with: .failure(Error.invalidData))
            //                 }
            //            }
        })
        return taskWrapper
    }
}
