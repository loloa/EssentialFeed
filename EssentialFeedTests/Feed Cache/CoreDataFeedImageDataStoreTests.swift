//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 01/10/2023.
//

import XCTest
import EssentialFeed

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
         
    }
 
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
         completion(.success(.none))
    }
 
}

final class CoreDataFeedImageDataStoreTests: XCTestCase {

    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
       
        let sut = makeSUT()
        
        expect(sut, completeWith: notFound(), for: anyURL())
         
    }
    
//    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
//            let sut = makeSUT()
//            let url = URL(string: "http://a-url.com")!
//            let nonMatchingURL = URL(string: "http://another-url.com")!
//
//            insert(anyData(), for: url, into: sut)
//
//            expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingURL)
//        }
    //MARK: -
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedImageDataStore {
        
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    private func notFound() -> FeedImageDataStore.Result {
        
        return .success(.none)
    }
    private func expect(_ sut: FeedImageDataStore,
                        completeWith expectedResult: FeedImageDataStore.Result,
                        for url: URL,
                        file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Waiting for load completion")
 
        sut.retrieve(dataForURL: url) { receivedResult in
             
            switch (receivedResult, expectedResult) {
                
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got instead \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

}
