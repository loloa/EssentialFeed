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
    
    private class Task: FeedImageDataLoaderTask {
        func cancel() {
             
        }
        
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
         
        return Task()
    }
    
    
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {

    //need to test that the decorator has the same behaviour as decoratee
    
    func test_initDoesNotLoadImageData() {
        
        let (_ , loader) = makeSUT()
 
        XCTAssertTrue(loader.loadedURLs.isEmpty, "Expected no loaded URLs")
        
    }
    /*
    func test_loadImageData_deliversImageDataOnLoadSuccess() {
        
        let nonEmptyData = anyData()
        let expectedResult: FeedImageDataLoader.Result = .success(nonEmptyData)
        
        let imageDataLoader = FeedImageDataLoaderSpy()
        
        let exp = expectation(description: "Waiting for completion")
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: imageDataLoader)
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            
            switch (expectedResult,receivedResult) {
                
            case let (.success(expectedData), .success(recevedData)):
                XCTAssertEqual(expectedData, recevedData, "Expected \(expectedData), instead got \(recevedData)")
            case (.failure , .failure):
                break
             default:
                XCTFail("Expected successfull load data, instead gor \(receivedResult)")
                
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    */
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, loader: FeedImageDataLoaderSpy) {
        
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private class FeedImageDataLoaderSpy: FeedImageDataLoader {
        
        private(set) var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        var loadedURLs: [URL] {
            return messages.map{ $0.url }
        }
        private class Task: FeedImageDataLoaderTask {
            func cancel() {
                 
            }
            
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
             
            return Task()
        }
        
        
        
    }
    
}
