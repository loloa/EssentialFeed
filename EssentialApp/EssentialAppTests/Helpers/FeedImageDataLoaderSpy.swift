//
//  FeedImageDataLoaderSpy.swift
//  EssentialAppTests
//
//  Created by אליסה לשין on 05/10/2023.
//

import EssentialFeed

class FeedImageDataLoaderSpy: FeedImageDataLoader {
    
    private(set) var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    var cancelledURLs = [URL]()
    
    var loadedURLs: [URL] {
        return messages.map{ $0.url }
    }
    private struct Task: FeedImageDataLoaderTask {
        
        let cancelCallback:() -> Void
        func cancel() {
            cancelCallback()
        }
        
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        messages.append((url, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    func complete(with error: NSError, at index: Int = 0){
        messages[index].completion(.failure(error))
    }
    
    func complete(with data: Data, at index: Int = 0) {
        messages[index].completion(.success(data))
    }
}
