//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 22/08/2023.
//

import XCTest
import EssentialFeed


class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let  timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map{ $0.local }
        }
    }
    //"Make it work. Make it right. Make it fast. In that order."—Kent Beck
    
    private struct CodableFeedImage: Codable {
        /* priority to decoupling, but if you think it hurts the performance , need to mesure before optimizing */
        
        /*
         
         We encourage you to measure your test suite performance over time. It should be automated, as part of your CI reports. Performance outliers should alert you to take action before they become a costly problem.
         
         To measure our test suite times, we used the following xcodebuild command to clean, build and test the EssentialFeed project using the EssentialFeed scheme:

         xcodebuild clean build test -project EssentialFeed/EssentialFeed.xcodeproj -scheme "EssentialFeed"
         */
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
 
    func retrieve(completion: @escaping FeedStore.RetrivalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
         }
        let decoder = JSONDecoder()
        do {
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
        
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion){
        
        let encoder = JSONEncoder()
        //let cache = Cache(feed: feed.map{ CodableFeedImage($0)}, timestamp: timestamp)
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

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
    // returns the same Data on twice call
    @discardableResult
    private func insert(_ cache:(feed: [LocalFeedImage], timestamp: Date), to sut: CodableFeedStore) -> Error? {
        let exp = expectation(description: "Waiting for cache retireval")
        var insertionError: Error?
        
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return insertionError
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
    //MARK: - Helpers
    
    func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore{
         
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        
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
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
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
