//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 30/08/2023.
//

import XCTest
import EssentialFeed

class CoreDataFeedStore: FeedStore {
    
    public init() {}
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
         
    }
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
         
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
 
}

final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    
    private func makeSUT() -> CoreDataFeedStore {
        let sut = CoreDataFeedStore()
        trackForMemoryLeaks(sut)
        return sut
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        
        let sut = makeSUT()
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
         
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
         
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
         
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
         
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
         
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
         
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
         
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
         
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
         
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
         
    }
    
    func test_storeSideEffects_runSerially() {
         
    }
    

   
}
