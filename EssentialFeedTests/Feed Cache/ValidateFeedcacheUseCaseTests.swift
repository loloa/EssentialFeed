//
//  ValidateFeedcacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 21/08/2023.
//

import XCTest
import EssentialFeed

final class ValidateFeedcacheUseCaseTests: XCTestCase {

    
    func test_init_doesNotMessageStoreUponCreation(){
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrivalError (){
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrival(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache (){
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrivalWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteNonExpiredCache (){
        let fixedDate = Date()
        let nonExpiredTimestamp = fixedDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let expectedImagesFeed = uniqueImageFeed()
        let (sut, store) = makeSUT()
 
        sut.validateCache()
        store.completeRetrival(with: expectedImagesFeed.local, timestamp: nonExpiredTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheOnExpiration (){
       
        let expectedImagesFeed = uniqueImageFeed()
        let fixedDate = Date()
        let expirationTimestamp = fixedDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedDate })
 
        sut.validateCache()
        store.completeRetrival(with: expectedImagesFeed.local, timestamp: expirationTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_deletesExpiredCache (){
       
        let fixedDate = Date()
        let expiredTimestamp = fixedDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let expectedImagesFeed = uniqueImageFeed()
        let (sut, store) = makeSUT()
 
        sut.validateCache()
        store.completeRetrival(with: expectedImagesFeed.local, timestamp: expiredTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache()
        sut = nil
        store.completeRetrival(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve])
        
    }
 
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init ,file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
 
 }

