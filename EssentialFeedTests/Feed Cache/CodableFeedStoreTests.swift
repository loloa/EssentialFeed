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
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
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
 
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValue() {

        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let exp = expectation(description: "Waiting for cache retireval")
        
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError,"Expected feed to be inserted successfully")
            exp.fulfill()
        }
         wait(for: [exp], timeout: 1.0)
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    // returns the same Data on twice call
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {

        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let exp = expectation(description: "Waiting for cache retireval")
        
        sut.insert(feed, timestamp: timestamp) { insertionError in
 
            XCTAssertNil(insertionError,"Expected feed to be inserted successfully")
            exp.fulfill()
         }
         
        wait(for: [exp], timeout: 1.0)
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    //MARK: - Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore{
         
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
                case (.empty, .empty):
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
