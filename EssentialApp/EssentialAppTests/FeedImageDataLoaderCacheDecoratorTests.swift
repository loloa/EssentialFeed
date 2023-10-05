//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by אליסה לשין on 05/10/2023.
//

import XCTest
import EssentialFeed


protocol FeedImageDataCache {
    
     typealias Result = Swift.Result<Void, Error>
     func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
 
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
       
        let task = decoratee.loadImageData(from: url) {  [weak self] result in
 
            completion( result.map{ data in
                self?.cache.save(data, for: url) { _ in }
                return data
            })
        }
         return task
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
    
    
    func test_loadImageData_cachesLoadedImageDataOnLoaderSuccess() {
        
        let imageData = anyData()
        let cache = CacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        
        expect(sut, completeWith: .success(imageData)) {
            loader.complete(with: imageData)
        }
        XCTAssertEqual(cache.messages, [.save(data: imageData, url: anyURL())], "Expected to cache loaded image data on success")
    }
    
    func test_loadImageData_doesNotSaveOnLoaderFailure() {
        
        let cache = CacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        expect(sut, completeWith: .failure(anyNSError())) {
            loader.complete(with: anyNSError())
        }
        
        XCTAssertTrue(cache.messages.isEmpty, "Expected cache not to save data on loader failure")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(cache: CacheSpy = .init(),file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, loader: FeedImageDataLoaderSpy) {
        
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private class CacheSpy: FeedImageDataCache {
        
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save(data: Data, url: URL)
        }
        
        func save(_ data: Data, for url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void) {
            messages.append(.save(data: data, url: url))
        }
 
    }
 
}
