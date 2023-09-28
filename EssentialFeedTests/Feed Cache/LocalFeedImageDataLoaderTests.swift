//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 28/09/2023.
//

import XCTest
import EssentialFeed


//should conform to FeedImageDataLoader

final class LocalFeedImageDataLoader {
    
    private let store: Any
    init(store: Any) {
        self.store = store
    }
}

final class LocalFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation( )  {
         
        let (_, store) = makeSUT()
        XCTAssertTrue(store.receivedMessages.isEmpty)
        
    }
    
    //MARK: --
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    //should conform to FeedStore
    private class FeedStoreSpy {
 
        private(set) var receivedMessages = [Any]()
    }

}
