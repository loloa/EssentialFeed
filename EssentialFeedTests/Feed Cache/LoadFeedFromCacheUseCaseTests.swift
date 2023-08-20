//
//  LOadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 20/08/2023.
//

import XCTest
import EssentialFeed
 
final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    //1. Execute "Load Image Feed" command with above data.
    func test_init_doesNotMessageStoreUponCreation(){
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    //2. System retrieves feed data from cache.
    func test_load_requestsCacheRetrival(){
        
        let (sut, store) = makeSUT()
        sut.load()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    // MArk: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init ,file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
}
