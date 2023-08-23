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
        let feed: [LocalFeedImage]
        let  timestamp: Date
    }
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
 
    func retrieve(completion: @escaping FeedStore.RetrivalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
         }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.feed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion){
        
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(feed: feed, timestamp: timestamp))
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

final class CodableFeedStoreTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
//        do {
//            try FileManager.default.removeItem(at: storeURL)
//            print("** Success! setiup.")
//        }catch {
//            print("** failed Cleared on SetUP \(error)")
//        }

    }
    
    override class func tearDown() {
        super.tearDown()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
//        do {
//             try FileManager.default.removeItem(at: storeURL)
//            print("** Success! tearDown.")
//        }catch {
//            print("**failed Cleared on tearDown \(error)")
//        }
    }

    //Empty cache works (before something is inserted)
    func test_retrieve_deliversEmptyOnEmptyCache() {
        
        let sut = CodableFeedStore()
        let exp = expectation(description: "Waiting for cache retireval")
        sut.retrieve { result in
            
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result , insted got \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    //Empty cache twice returns empty (no side effect)
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {

        let sut = CodableFeedStore()
        let exp = expectation(description: "Waiting for cache retireval")
        sut.retrieve { firstResult in

            sut.retrieve { secondResultesult in

                switch (firstResult,secondResultesult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected empty result , insted got \(firstResult), \(secondResultesult)")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieveCacheAfterInsertingToEmptycache_deliversInsertedValue() {

        let sut = CodableFeedStore()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let exp = expectation(description: "Waiting for cache retireval")
        
        sut.insert(feed, timestamp: timestamp) { insertionError in
 
            XCTAssertNil(insertionError,"Expected feed to be inserted successfully")
            
            sut.retrieve { retrieveResult in

                switch retrieveResult {
                case let .found(feed: retrieveFeed, timestamp: retrievedTimestamp):
                    
                    XCTAssertEqual(retrieveFeed, feed)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                    break
                default:
                    XCTFail("Expected found result with \(feed) timestamp\(timestamp) , insted got \(retrieveResult)")
                }
                exp.fulfill()
            }
        }
         
        wait(for: [exp], timeout: 1.0)
    }
     
}
