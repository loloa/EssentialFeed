//
//  ValidateFeedcacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 21/08/2023.
//

import XCTest
import EssentialFeed

final class ValidateFeedcacheUseCaseTests: XCTestCase {

    
    func test_init_doesNotMessageStoreUponCreation(){
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrivalError (){
        let (sut, store) = makeSUT()
        
        sut.validateCache { _ in }
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache (){
        let (sut, store) = makeSUT()
        
        sut.validateCache { _ in }
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteNonExpiredCache (){
        let fixedDate = Date()
        let nonExpiredTimestamp = fixedDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let expectedImagesFeed = uniqueImageFeed()
        let (sut, store) = makeSUT()
 
        sut.validateCache { _ in }
        store.completeRetrieval(with: expectedImagesFeed.local, timestamp: nonExpiredTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheOnExpiration (){
       
        let expectedImagesFeed = uniqueImageFeed()
        let fixedDate = Date()
        let expirationTimestamp = fixedDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedDate })
 
        sut.validateCache { _ in }
        store.completeRetrieval(with: expectedImagesFeed.local, timestamp: expirationTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_deletesExpiredCache (){
       
        let fixedDate = Date()
        let expiredTimestamp = fixedDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let expectedImagesFeed = uniqueImageFeed()
        let (sut, store) = makeSUT()
 
        sut.validateCache { _ in }
        store.completeRetrieval(with: expectedImagesFeed.local, timestamp: expiredTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache { _ in }
        sut = nil
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve])
        
    }
 
    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
            let (sut, store) = makeSUT()
            let deletionError = anyNSError()

            expect(sut, toCompleteWith: .failure(deletionError), when: {
                store.completeRetrieval(with: anyNSError())
                store.completeDeletion(with: deletionError)
            })
        }

        func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
            let (sut, store) = makeSUT()

            expect(sut, toCompleteWith: .success(()), when: {
                store.completeRetrieval(with: anyNSError())
                store.completeDeletionSuccessfully()
            })
        }

    
    //MARK: - Helpers
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.ValidationResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
            let exp = expectation(description: "Wait for load completion")

            sut.validateCache { receivedResult in
                switch (receivedResult, expectedResult) {
                case (.success, .success):
                    break

                case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)

                default:
                    XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
                }

                exp.fulfill()
            }

            action()
            wait(for: [exp], timeout: 1.0)
        }

    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init ,file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
 
 }

