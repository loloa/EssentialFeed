//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by אליסה לשין on 04/10/2023.
//

import XCTest
import EssentialFeed
import EssentialApp
 
final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversFeedonLoadSuccess() {
        
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed))
        
        expect(sut, completeWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        
        let error = anyNSError()
        let sut =  makeSUT(loaderResult: .failure(error))
        
        expect(sut, completeWith: .failure(error))
    }
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        
        let feed = uniqueFeed()
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .success(feed), cache: cache)
        sut.load { _ in
            
        }
        
        XCTAssertEqual(cache.messages, [.save(feed)], "Expected to cache loaded feed on success")
    }
    
    func test_load_doesNotSaveOnLoaderFailure() {
        
        let error = anyNSError()
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .failure(error), cache: cache)
        sut.load { _ in
            
        }
        
        XCTAssertTrue(cache.messages.isEmpty, "Expected not to cache on loader failure")
    }
    
    //MARK: - Helpers
    
    private func makeSUT(loaderResult: FeedLoader.Result, cache: CacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        
        let loader = FeedLoaderStub(result:  loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private class CacheSpy: FeedCache {
        
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        func save(_ feed: [EssentialFeed.FeedImage], comletion: @escaping (FeedCache.Result) -> Void) {
            messages.append(.save(feed))
            comletion(.success(()))
        }
    }
}