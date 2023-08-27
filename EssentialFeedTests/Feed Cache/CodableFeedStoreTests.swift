//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 22/08/2023.
//

import XCTest
import EssentialFeed


//this is composition
typealias FailableFeedStoreSpecs = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs


final class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
    
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
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed: feed, timestamp: timestamp), to: sut)
        expect(sut, toRetrieve: .empty)
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
//        let noPermissionsDirectory = cachesDirectory()
//        let sut = makeSUT(storeURL: noPermissionsDirectory)
//        let deletionError = deleteCache(sut: sut)
//        XCTAssertNotNil(deletionError, "Expected cache deletion failure with error")
//        expect(sut, toRetrieve: .empty)
        
            let noDeletePermissionURL = noDeletePermissionURL()
            let sut = makeSUT(storeURL: noDeletePermissionURL)
            let deletionError = deleteCache(sut: sut)
            XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
            
    }
    
    func test_delete_hasNoSideEffectOnDeletionError() {
 
            let noDeletePermissionURL = noDeletePermissionURL()
            let sut = makeSUT(storeURL: noDeletePermissionURL)
            deleteCache(sut: sut)
            expect(sut, toRetrieve: .empty)
    }
    
    func test_sideEffectsAreSerial() {
        
        let sut = makeSUT()
         
        var operationsOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            operationsOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            operationsOrder.append(op2)
            op2.fulfill()
        }
         
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            operationsOrder.append(op3)
            op3.fulfill()
        }
        waitForExpectations(timeout: 5.0)
        XCTAssertEqual([op1, op2, op3], operationsOrder, "Expected side efects to run serially but operations finished in the wrong order")
         
    }
     
      
    //MARK: - Helpers
    
    func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
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
    
    private func noDeletePermissionURL() -> URL {
      return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
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
