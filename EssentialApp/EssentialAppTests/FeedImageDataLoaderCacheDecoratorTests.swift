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

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
    
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
 
}
