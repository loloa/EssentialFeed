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
        
        sut.validateCache()
        store.completeRetrival(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache (){
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrivalWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteCacheOnLessThanSevenDaysOldCache (){
        let fixedDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedDate.adding(days: -7).adding(seconds: 1)
        let expectedImagesFeed = uniqueImageFeed()
        let (sut, store) = makeSUT()
 
        sut.validateCache()
        store.completeRetrival(with: expectedImagesFeed.local, timestamp: lessThanSevenDaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init ,file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
 
    private func anyNSError()  -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: nil, location: nil, url: anyURL())
    }
    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let models = [uniqueImage(), uniqueImage()]
        let local = models.map{ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
        return (models, local)
    }
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
}
private extension Date {
    
    func adding(days: Int) -> Date {
        
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    func adding(seconds: TimeInterval) -> Date {
        
        return self + seconds
    }
}
