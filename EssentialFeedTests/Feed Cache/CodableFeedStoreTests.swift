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
    
    private struct CodableFeedImage: Codable {
        /* priority to decoupling, but if you think it hurts the performance , need to mesure before optimizing */
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
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
 
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
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
//        do {
//            try FileManager.default.removeItem(at: storeURL)
//            print("** Success! setiup.")
//        }catch {
//            print("** failed Cleared on SetUP \(error)")
//        }
    }
    
    override  func tearDown() {
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
