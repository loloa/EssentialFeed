//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 22/08/2023.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    
    func retrieve(completion: @escaping FeedStore.RetrivalCompletion) {
        
        completion(.empty)
    }
}

final class CodableFeedStoreTests: XCTestCase {

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

}
