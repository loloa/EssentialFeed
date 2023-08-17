//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 16/08/2023.
//

import XCTest
import EssentialFeed

protocol FeedStore{
    typealias DeletionCompletion = ((Error?) -> Void)
    typealias InsertionCompletion = ((Error?) -> Void)
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}



class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date){
        self.store = store
        self.currentDate = currentDate
    }
 
    func save(_ items: [FeedItem], comletion: @escaping (Error?) -> Void ) {
        store.deleteCachedFeed {[weak self] error in
            
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                comletion(cacheDeletionError)
            } else {
                cache(items, with: comletion)
            }
         }
    }
    
    private func cache(_ items: [FeedItem], with completion: @escaping (Error?) -> Void) {
        self.store.insert(items, timestamp: self.currentDate()) {[weak self] error in
            guard let self = self else { return }
            completion(error)
        }
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    
    
    func test_init_doesNotMessageStoreUponCreation(){
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let items = [uniqueItem(),uniqueItem()]
        let (sut, store) = makeSUT()
        
        sut.save(items) { _ in }
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_doesNotRequestCacheInsertionOnDeletionError(){
        let deletionError = anyNSError()
        let items = [uniqueItem(),uniqueItem()]
        let (sut, store) = makeSUT()
        
        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items = [uniqueItem(),uniqueItem()]
        let (sut, store) = makeSUT(currentDate:{ timestamp })
        
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
        
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        
        let deletionError = anyNSError()
        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
     }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccessfullCacheInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
     }
    func test_save_doesNotDeliverDeletionErrorAfterSUTHasBeenDeallocated() {
        
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [Error?]()
        sut?.save([uniqueItem()], comletion: { receivedResults.append($0)})
        
        sut = nil
        
        store.completeDeletion(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTHasBeenDeallocated() {
        
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [Error?]()
        sut?.save([uniqueItem()], comletion: { receivedResults.append($0)})
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init ,file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    private class FeedStoreSpy: FeedStore {
        
        /*
         we have order dependency on store insert can be done only after deletion
         so we need garantee not only that the methods were called but also called in write order
         we ned to merge all info in one stuff to use it in assertions
         */
        
        enum ReceivedMessages: Equatable {
            case deleteCachedFeed
            case insert([FeedItem], Date)
        }
        private (set) var receivedMessages = [ReceivedMessages]()
        
        private var deletionCompletions = [DeletionCompletion]()
        private var insertionCompletions = [InsertionCompletion]()
        
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion){
            deletionCompletions.append(completion)
            receivedMessages.append(.deleteCachedFeed)
        }
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        func completeDeletionSuccessfully(at index: Int = 0){
            deletionCompletions[index](nil)
        }
        func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletions.append(completion)
            receivedMessages.append(.insert(items, timestamp))
        }
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
        
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        var receivedError: Error?
        let exp = expectation(description: "Wait for save complition")
        sut.save([uniqueItem()]) { error in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    private func anyNSError()  -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
