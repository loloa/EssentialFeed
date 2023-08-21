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

    //3. System validates cache is less than seven days old.
    
    func test_load_deleiversCachedImagesOnLessThanSevendaysOldCache() {
        
       // let lessThanSevendaysOldTimeStamp = currentDate - (7 * 24 * 60 * 60) + 1sec
        let fixedCurrentDate = Date()
        let lessThanSevendaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds:1)
        let feed = uniqueImageFeed()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
 
        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrival(with: feed.local, timestamp: lessThanSevendaysOldTimeStamp)
        }
    }
    
    //#### Expired cache course (sad path):
    //1. System delivers no feed images.
    
    func test_load_deleiversNoImagesOnSevendaysOldCache() {
        
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevendaysOldTimeStamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
 
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrival(with: feed.local, timestamp: sevendaysOldTimeStamp)
        }
    }
    
    func test_load_deleiversNoImagesOnMoreThanSevendaysOldCache() {
        
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let moreThansevendaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
 
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrival(with: feed.local, timestamp: moreThansevendaysOldTimeStamp)
        }
    }
 
    
    // #### Retrieval error course (sad path):
    //1. System deletes cache.

    func test_load_deletesCacheOnretrivalError (){
        
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrival(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
 
    }
    
    func test_load_doesNotdeletesCacheOnEmptyCache (){
        
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrivalWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
 
    }
    func test_load_doesNotDeleteCacheOnLessThanSevenDaysOldCache (){
       
        let fixedDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedDate.adding(days: -7).adding(seconds: 1)
        let expectedImagesFeed = uniqueImageFeed()
        let (sut, store) = makeSUT()
 
        sut.load { _ in }
        store.completeRetrival(with: expectedImagesFeed.local, timestamp: lessThanSevenDaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_deletesSevenDaysOldCache (){
       
        let fixedDate = Date()
        let sevenDaysOldTimestamp = fixedDate.adding(days: -7)
        let expectedImagesFeed = uniqueImageFeed()
        let (sut, store) = makeSUT()
 
        sut.load { _ in }
        store.completeRetrival(with: expectedImagesFeed.local, timestamp: sevenDaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_load_deletesMoreThanSevenDaysOldCache (){
       
        let fixedDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedDate.adding(days: -7).adding(days: -1)
        let expectedImagesFeed = uniqueImageFeed()
        let (sut, store) = makeSUT()
 
        sut.load { _ in }
        store.completeRetrival(with: expectedImagesFeed.local, timestamp: moreThanSevenDaysOldTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
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
    private func anyNSError()  -> NSError {
        return NSError(domain: "any error", code: 0)
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
