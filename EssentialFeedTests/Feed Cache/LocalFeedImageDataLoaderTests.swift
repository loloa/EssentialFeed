//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 28/09/2023.
//

import XCTest
import EssentialFeed


final class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation( )  {
        
        let (_, store) = makeSUT()
        XCTAssertTrue(store.receivedMessages.isEmpty)
        
    }
    
    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failed()) {
            store.complete(with: LocalFeedImageDataLoader.Error.failed)
        }
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound()) {
            store.complete(with: .none)
        }
    }
    
    func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let foundData = anyData()
        
        expect(sut, toCompleteWith: .success(foundData), when: {
            store.complete(with: foundData)
        })
    }
    
    func test_cancelLoadImageDataURLTask_doesNotDeliverResultAfterCancellingTask() {
        
        let foundData = anyData()
        
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        var received = [FeedImageDataLoader.Result]()
        
        let task = sut.loadImageData(from: url) { received.append($0)}
        
        task.cancel()
        
        client.complete(with: foundData)
        client.complete(with: .none)
        client.complete(with: anyNSError())
        
        XCTAssertTrue(received.isEmpty, "Expected not to deliver result after cancelling")
    }
    func test_LoadImageDataURLTask_doesNotDeliverDataAfterInstancehasBeenDeallocated() {
        
        let store = StoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var received = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) { received.append($0) }
        
        sut = nil
        store.complete(with: anyData())
        
        XCTAssertTrue(received.isEmpty, "Expected no received results after instance has been deallocated")
    }
    
    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        sut.save(data, for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
    }
    //MARK: --
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
        
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func failed() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.Error.failed)
    }
    private func notFound() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.Error.notFound)
    }
    
    private func never(file: StaticString = #file, line: UInt = #line) {
        XCTFail("Expected no no invocations", file: file, line: line)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader,toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Waiting for load")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            
            switch(receivedResult, expectedResult) {
                
            case let (.failure(receivedError as LocalFeedImageDataLoader.Error), .failure(expectedError as LocalFeedImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            default:
                XCTFail("Expexted result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private class StoreSpy: FeedImageDataStore {
        
        enum Message: Equatable {
            case insert(data: Data, for: URL)
            case retrieve(dataFor: URL)
        }
        
        private(set) var completions = [(FeedImageDataStore.Result) -> Void]()
        private(set) var receivedMessages = [Message]()
        
        func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
            receivedMessages.append(.insert(data: data, for: url))
        }
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
            receivedMessages.append(.retrieve(dataFor: url))
            completions.append(completion)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
        func complete(with data: Data?, at index: Int = 0) {
            completions[index](.success(data))
        }
    }
    
}
