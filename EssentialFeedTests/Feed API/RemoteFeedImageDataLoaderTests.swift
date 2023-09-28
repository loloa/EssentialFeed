//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 26/09/2023.
//

import XCTest
import EssentialFeed
 
final class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadeImageDataFromURL_requestsDataFromURL() {
        
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        _ = sut.loadImageData(from: url, completion: { _ in })
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURL() {
        
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        _ = sut.loadImageData(from: url, completion: { _ in })
        _ = sut.loadImageData(from: url, completion: { _ in })
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversConnectivityError() {
        
        let expectedResult: FeedImageDataLoader.Result = failure(.connectivity)
        
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: expectedResult) {
            client.complete(with: anyNSError())
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        
        let (sut, client) = makeSUT()
        
        let expectedResult: FeedImageDataLoader.Result = failure(.invalidData)
        let statuses = [199, 201, 300, 400, 1000]
        
        statuses.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: expectedResult) {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            }
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        
        let (sut, client) = makeSUT()
        
        let expectedResult: FeedImageDataLoader.Result = failure(.invalidData)
        
        expect(sut, toCompleteWith: expectedResult) {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData)
        }
    }
    
    func test_loadImageDataFromURL_deliversReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let nonEmptyData = Data("non-empty data".utf8)
        let expectedResult: FeedImageDataLoader.Result = .success(nonEmptyData)
        
        expect(sut, toCompleteWith: expectedResult, when: {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        })
    }
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
        
        
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        
        var result = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) { result.append($0)}
        sut = nil
        client.complete(withStatusCode: 200, data: anyData())
        XCTAssertTrue(result.isEmpty, "Expected not to deliver result after deallocation")
         
    }
    
    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
            let (sut, client) = makeSUT()
            let url = URL(string: "https://a-given-url.com")!

            let task = sut.loadImageData(from: url) { _ in }
            XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")

            task.cancel()
            XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
        }
    
    func test_cancelLoadImageDataURLTask_doesNotDeliverResult() {
        
            let nonEmptyData = Data("non-empty data".utf8)
        
            let (sut, client) = makeSUT()
            let url = URL(string: "https://a-given-url.com")!

            var received = [FeedImageDataLoader.Result]()
        
            let task = sut.loadImageData(from: url) { received.append($0)}
            XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")

            task.cancel()
            
            client.complete(withStatusCode: 404, data: anyData())
            client.complete(withStatusCode: 200, data: nonEmptyData)
            client.complete(with: anyNSError())
 
            XCTAssertTrue(received.isEmpty, "Expected not to deliver result after cancelling")
        }
    
    // MARK: -
 
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
   
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let url = anyURL()
        
        let exp = expectation(description: "Waiting for completion")
        
        _ = sut.loadImageData(from: url) { receivedResult in
            
            switch(receivedResult, expectedResult) {
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
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
}
