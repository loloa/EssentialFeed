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

final class FeedLoaderCacheDecoratorTests: XCTestCase {

    func test_load_deliversFeedonLoadSuccess() {
        
        let feed = uniqueFeed()
        let feedloader = FeedLoaderStub(result: .success(feed))
        let sut = FeedLoaderCacheDecorator(decoratee: feedloader)
        
        expect(sut, completeWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        
        let error = anyNSError()
        let feedloader = FeedLoaderStub(result: .failure(error))
        let sut = FeedLoaderCacheDecorator(decoratee: feedloader)
        
        expect(sut, completeWith: .failure(error))
    }
    private func expect(_ sut: FeedLoader, completeWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
        
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected successful load feed result, instead got \(expectedResult)}", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
 
    private func uniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http://any-url.com")!)]
    }

}
