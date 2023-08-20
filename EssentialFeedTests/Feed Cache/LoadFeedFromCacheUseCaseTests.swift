//
//  LOadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 20/08/2023.
//

import XCTest
import EssentialFeed
 
final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    //1. Execute "Load Image Feed" command with above data.
    func test_init_doesNotMessageStoreUponCreation(){
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    //2. System retrieves feed data from cache.
    func test_load_requestsCacheRetrival(){
        
        let (sut, store) = makeSUT()
        sut.load { _ in }
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    //#### Retrieval error course (sad path):
    //1. System delivers error.
    func test_load_failsOnretrivalError() {
        
        let retrievalError = anyNSError()
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWith: .failure(retrievalError), with: {
            store.completeRetrival(with: retrievalError)
        })
         
    }
    
    
    //#### Empty cache course (sad path):
    //1. System delivers no feed images.
    
    func test_load_deliversNoImagesOnEmptyCase(){
 
        let (sut, store) = makeSUT()
 
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrivalWithEmptyCache()
        }
    }

    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init ,file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, with action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Waiting for complition")
 
        sut.load { receivedResult in
            
            switch (receivedResult, expectedResult) {
                
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), instead got \(receivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        }
          action()
        
        wait(for: [exp], timeout: 1.0)
 
    }
    
    private func anyNSError()  -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
}
