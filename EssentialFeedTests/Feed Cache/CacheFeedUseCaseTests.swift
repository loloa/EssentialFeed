//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 16/08/2023.
//

import XCTest
import EssentialFeed

class FeedStore {
    
    typealias DeletionCompletion = ((Error?) -> Void)
    typealias InsertionCompletion = ((Error?) -> Void)
    
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

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date){
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], comletion: @escaping (Error?) -> Void ) {
        store.deleteCachedFeed {[unowned self] error in
            
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate(), completion: comletion )
            }else {
                comletion(error)
            }
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
        
        let items = [uniqueItem(),uniqueItem()]
        let (sut, store) = makeSUT()
        
        let deletionError = anyNSError()
        var receivedError: Error?
        
        let exp = expectation(description: "Wait for save complition")
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(receivedError as NSError?, deletionError)
    }
    
    func test_save_failsOnInsertionError() {
        
        let items = [uniqueItem(),uniqueItem()]
        let (sut, store) = makeSUT()
        
        let insertionError = anyNSError()
        var receivedError: Error?
        
        let exp = expectation(description: "Wait for save complition")
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertion(with: insertionError)
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(receivedError as NSError?, insertionError)
    }
    
    func test_save_succeedsOnSuccessfullCacheInsertion() {
        
        let items = [uniqueItem(),uniqueItem()]
        let (sut, store) = makeSUT()
       
        var receivedError: Error?
        
        let exp = expectation(description: "Wait for save complition")
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()
        wait(for: [exp], timeout: 1)
        XCTAssertNil(receivedError)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init ,file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
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
