//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 16/08/2023.
//

import XCTest

class FeedStore {
    
    var deleteCachedFeedCallCount: Int = 0
}

class LocalFeedLoader {
    init(store: FeedStore){
        
    }
}

final class CacheFeedUseCaseTests: XCTestCase {

    
    func test_init_doesNotDeleteCacheUponCreation(){
        
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

}
