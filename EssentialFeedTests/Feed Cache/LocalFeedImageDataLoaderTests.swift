//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 28/09/2023.
//

import XCTest
import EssentialFeed


protocol FeedImageDataStore {
    
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}

final class LocalFeedImageDataLoader: FeedImageDataLoader {
 
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {
             
        }
     }
    
    public enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    private let store: FeedImageDataStore
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        
        store.retrieve(dataForURL: url) { result in
           
            completion( result
                .mapError{ _ in Error.failed }
                .flatMap{ _ in .failure( Error.notFound ) })
         }
        return Task()
    }
}

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
            case retrieve(dataFor: URL)
        }
        
        private(set) var receivedMessages = [Message]()
        
        private(set) var completions = [(FeedImageDataStore.Result) -> Void]()
        
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
