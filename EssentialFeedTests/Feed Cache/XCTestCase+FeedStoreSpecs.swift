//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 27/08/2023.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    @discardableResult
     func insert(_ cache:(feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Waiting for cache retireval")
        var insertionError: Error?
        
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    @discardableResult
     func deleteCache(sut: FeedStore) -> Error? {
        
        let exp = expectation(description: "Waitong for cache deletion")
        var deletionError: Error?
        
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
     func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
     func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Waiting for cache retireval")
        sut.retrieve { retrievedResult in
            
            switch (retrievedResult,expectedResult) {
            case (.empty, .empty),
                (.failure, .failure):
                break
            case let (.found(feed: retrievedFeed, timestamp: retrievedTimestamp), .found(feed: expectedFeed, timestamp: expectedResultTimestamp)):
                
                XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedResultTimestamp, file: file, line: line)
                break
            default:
                XCTFail("Expected to retrieve \(expectedResult), got instead \(retrievedResult)")
            }
            exp.fulfill()
            
        }
        wait(for: [exp], timeout: 1.0)
    }
    
}
