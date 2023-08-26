//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 22/08/2023.
//

import XCTest
import EssentialFeed
 
final class CodableFeedStoreTests: XCTestCase {
    
    override  func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override  func tearDown() {
        super.tearDown()
        setupEmptyStoreState()
    }
    
    //Empty cache works (before something is inserted)
    func test_retrieve_deliversEmptyOnEmptyCache() {
        
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
    }
    
    //Empty cache twice returns empty (no side effect)
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        insert((feed, timestamp), to: sut)
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overidesPrevioslyInsertedCache() {
        
        let sut = makeSUT()
        let feed = uniqueImageFeed()
        let timestamp = Date()
        
        let firstInsertionError = insert((feed: feed.local, timestamp: timestamp), to: sut)
        XCTAssertNil(firstInsertionError,"Expected to insert cache successfully")
        
        let latestFeed = uniqueImageFeed()
        let latestTimestamp = Date()
        let latestinsertionError = insert((feed: latestFeed.local, timestamp: latestTimestamp), to: sut)
        XCTAssertNil(latestinsertionError, "Expected to override cache successfully")
        expect(sut, toRetrieve: .found(feed: latestFeed.local, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let error = insert((feed: feed, timestamp: timestamp), to: sut)
        XCTAssertNotNil(error,"Expected cache insertion to fail with an error")
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache() {
        
        let sut = makeSUT()
        
        let deletionError = deleteCache(sut: sut)
        XCTAssertNil(deletionError, "Expected empty cache no side effects")
        expect(sut, toRetrieve: .empty)
        
    }
    
    func test_delete_emptiesPrevioslyInsertedCache() {
        
        let sut = makeSUT()
        
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed: feed, timestamp: timestamp), to: sut)
        XCTAssertNil(insertionError, "Expexted insert ssuccess got error")
        
        let deletionError = deleteCache(sut: sut)
        XCTAssertNil(deletionError, "Expected non- empty cache succeed")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noPermissionsDirectory = cachesDirectory()
        
        let sut = makeSUT(storeURL: noPermissionsDirectory)
        let deletionError = deleteCache(sut: sut)
        XCTAssertNotNil(deletionError, "Expected cache deletion failure with error")
        expect(sut, toRetrieve: .empty)
    }
    
    //MARK: - Helpers
    
    func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func insert(_ cache:(feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Waiting for cache retireval")
        var insertionError: Error?
        
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    private func deleteCache(sut: FeedStore) -> Error? {
        
        let exp = expectation(description: "Waitong for cache deletion")
        var deletionError: Error?
        
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        
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
    private func testSpecificStoreURL() -> URL {
        
        //CodableFeedStoreTests.store
        /*
         we made sure to use the cachesDirectory which is a place for “discardable cache files” and the OS itself can clean up when necessary. (As opposed to the documentDirectory, which the developer is fully responsible for maintaining).
         */
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    private func undoSideEffects() {
        deleteStoreArtifacts()
    }
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
}
