//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 30/08/2023.
//

import XCTest
import EssentialFeed


final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    
    private func makeSUT() -> CoreDataFeedStore {
        
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let sut = try! CoreDataFeedStore(bundle: bundle)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        
        let sut = makeSUT()
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
         
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
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
