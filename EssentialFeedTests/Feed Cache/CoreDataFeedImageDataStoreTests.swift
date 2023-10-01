//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 01/10/2023.
//

import XCTest
import EssentialFeed

extension CoreDataFeedStore: FeedImageDataStore {
    
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
         completion(.success(.none))
    }
 
}

final class CoreDataFeedImageDataStoreTests: XCTestCase {

    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        
        
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        
        let exp = expectation(description: "Waiting for load completion")
        let expectedResult = FeedImageDataStore.Result.success(.none)
        
        sut.retrieve(dataForURL: anyURL()) { receivedResult in
             
            switch (receivedResult, expectedResult) {
                
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData)
                
            default:
                XCTFail("Expected \(expectedResult), got instead \(receivedResult)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

}
