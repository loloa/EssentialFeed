//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by אליסה לשין on 05/10/2023.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    
    private let decoratee: FeedImageDataLoader
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
 
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url, completion: completion)
     }
 
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {
    
    //need to test that the decorator has the same behaviour as decoratee
    
    func test_initDoesNotLoadImageData() {
        
        let (_ , loader) = makeSUT()
        
        XCTAssertTrue(loader.loadedURLs.isEmpty, "Expected no loaded URLs")
        
    }
    
    func test_loadImageData_loadsFromLoader() {
        
        let url = anyURL()
        let (sut , loader) = makeSUT()
        _ = sut.loadImageData(from: url) {_ in }
        XCTAssertEqual(loader.loadedURLs, [url], "Expected to load url from loader")
    }
    
    func test_cancelLoadImageData_cancelsLoaderTask() {
        
        let url = anyURL()
        let (sut , loader) = makeSUT()
        let task = sut.loadImageData(from: url) {_ in }
        task.cancel()
        XCTAssertEqual(loader.cancelledURLs, [url], "Expected to cancel requested url from loader")
    }
    
    func test_loadImageData_deliversDataOnLoaderSuccess() {
 
        let (sut, loader) = makeSUT()
        
        expect(sut, completeWith: .success(anyData())) {
            loader.complete(with: anyData())
        }
     }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
 
        let (sut, loader) = makeSUT()
        
        expect(sut, completeWith: .failure(anyNSError())) {
            loader.complete(with: anyNSError())
        }
     }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, loader: FeedImageDataLoaderSpy) {
        
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func expect(_ sut: FeedImageDataLoader, completeWith expectedResult: FeedImageDataLoader.Result, action:() -> Void,  file: StaticString = #file, line: UInt = #line ) {
 
        let exp = expectation(description: "Waiting for completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            
            switch (expectedResult,receivedResult) {
                
            case let (.success(expectedData), .success(recevedData)):
                XCTAssertEqual(expectedData, recevedData, "Expected \(expectedData), instead got \(recevedData)", file: file, line: line)
            case (.failure , .failure):
                break
            default:
                XCTFail("Expected successfull load data, instead gor \(receivedResult)", file: file, line: line)
                
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private class FeedImageDataLoaderSpy: FeedImageDataLoader {
        
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
    
}
