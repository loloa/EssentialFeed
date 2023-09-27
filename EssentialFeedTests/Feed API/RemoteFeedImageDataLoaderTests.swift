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
 
    func loadImageData(from url: URL, completion: @escaping (Any) -> Void) {
        
        client.get(from: url, completion: {_ in })
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
    
    // MARK: -
    
    private class HTTPClientSpy: HTTPClient {
   
         var requestedURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requestedURLs.append(url)
        }
    }
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
        
    }

}
