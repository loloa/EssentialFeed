//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 16/08/2023.
//

import XCTest
import EssentialFeed

class FeedStore {
    
    var deleteCachedFeedCallCount: Int = 0
    
    func deleteCachedFeed(){
        deleteCachedFeedCallCount += 1
        
    }
}

class LocalFeedLoader {
    let store: FeedStore
    init(store: FeedStore){
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

final class CacheFeedUseCaseTests: XCTestCase {

    
    func test_init_doesNotDeleteCacheUponCreation(){
        
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        
        let items = [uniqueItem(),uniqueItem()]
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        sut.save(items)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    //MARK: - Helpers
    private func uniqueItem() -> FeedItem {
         return FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL())
    }

    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
}
