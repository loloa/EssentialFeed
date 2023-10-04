//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by אליסה לשין on 04/10/2023.
//

import XCTest
import EssentialFeed

final class FeedLoaderCacheDecorator: FeedLoader {
    
    private let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
}

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
    
    //MARK: - Helpers
    
    func makeSUT(loaderResult: FeedLoader.Result,file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        
        let loader = FeedLoaderStub(result:  loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
  }
