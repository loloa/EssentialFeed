//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 26/09/2023.
//

import XCTest

final class RemoteFeedImageDataLoader {
    
    init(client: Any) {
        
    }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    // MARK: -
    
    private class HTTPClientSpy {
        
         var requestedURLs = [URL]()
    }
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
        
    }

}
