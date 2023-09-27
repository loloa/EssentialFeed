//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 26/09/2023.
//

import XCTest
import EssentialFeed

final class RemoteFeedImageDataLoader {
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
 
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        
        client.get(from: url, completion: { result in
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case .success:
                completion(.failure(Error.invalidData))
             }
        })
    }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadeImageDataFromURL_requestsDataFromURL() {
        
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        sut.loadImageData(from: url, completion: { _ in })
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURL() {
        
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        sut.loadImageData(from: url, completion: { _ in })
        sut.loadImageData(from: url, completion: { _ in })
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
 
        let supposedError = anyNSError()
        let expectedResult: FeedImageDataLoader.Result = .failure(supposedError)
        
        let (sut, client) = makeSUT()
       
        expect(sut, toCompleteWith: expectedResult) {
            client.complete(with: supposedError, at: 0)
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
    
    // MARK: -
    
    private class HTTPClientSpy: HTTPClient {
 
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map{ $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
     }

    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
         return .failure(error)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let url = anyURL()
        
        let exp = expectation(description: "Waiting for completion")
        
        sut.loadImageData(from: url) { receivedResult in
             
            switch(receivedResult, expectedResult) {
 
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            default:
                break
            }
            exp.fulfill()
        }
        action()
         
        wait(for: [exp], timeout: 1.0)
    }
}
