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
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    // MARK: -
    
    private class HTTPClientSpy {
        
         var requestedURLs = [URL]()
    }

}
