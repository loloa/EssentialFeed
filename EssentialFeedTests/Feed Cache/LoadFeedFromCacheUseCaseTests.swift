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
            store.completeRetrieval(with: retrievalError)
        })
         
    }
    
    
    //#### Empty cache course (sad path):
    //1. System delivers no feed images.
    
    func test_load_deliversNoImagesOnEmptyCase(){
 
        let (sut, store) = makeSUT()
 
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }

    //3. System validates cache is less than seven days old.
    
    func test_load_deleiversCachedImagesOnNonExpiredCache() {
        
       // let lessThanSevendaysOldTimeStamp = currentDate - (7 * 24 * 60 * 60) + 1sec
        let fixedCurrentDate = Date()
        let nonExpiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds:1)
        let feed = uniqueImageFeed()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
 
        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimeStamp)
        }
    }
    
    //#### Expired cache course (sad path):
    //1. System delivers no feed images.
    
    func test_load_deleiversNoImagesOnCacheExpiration() {
        
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
 
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local, timestamp: expirationTimeStamp)
        }
    }
    
    func test_load_deleiversNoImagesOnExpiredCache() {
        
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
 
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local, timestamp: expiredTimeStamp)
        }
    }
 
    
    // #### Retrieval error course (sad path):
    //1. System deletes cache.
    
    func test_load_hasNoSideEffectsOnretrivalError (){
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
 
    func test_load_hasNoSideEffectOnEmptyCache (){
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnNonExpiredCache (){
       
        let fixedDate = Date()
        let nonExpiredTimestamp = fixedDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let expectedImagesFeed = uniqueImageFeed()
        let (sut, store) = makeSUT()
 
        sut.load { _ in }
        store.completeRetrieval(with: expectedImagesFeed.local, timestamp: nonExpiredTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnCacheExpiration (){
       
        let expectedImagesFeed = uniqueImageFeed()
        let fixedDate = Date()
        let expirationTimestamp = fixedDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedDate })
 
        sut.load { _ in }
        store.completeRetrieval(with: expectedImagesFeed.local, timestamp: expirationTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnExpiredCache (){
       
        let fixedDate = Date()
        let expiredTimestamp = fixedDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let expectedImagesFeed = uniqueImageFeed()
        let (sut, store) = makeSUT()
 
        sut.load { _ in }
        store.completeRetrieval(with: expectedImagesFeed.local, timestamp: expiredTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanseHasBeenDealocated() {
        
        var (sut, store): (LocalFeedLoader?, FeedStoreSpy) = makeSUT()
        
        var capturedResult = [LocalFeedLoader.LoadResult]()
        sut?.load { capturedResult.append($0)}
        sut = nil
        store.completeRetrievalWithEmptyCache()
        XCTAssertTrue(capturedResult.isEmpty)
         
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
}
 
