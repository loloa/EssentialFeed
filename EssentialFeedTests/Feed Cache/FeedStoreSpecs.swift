//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 27/08/2023.
//

import Foundation


protocol FeedStoreSpecs {
    
     func test_retrieve_deliversEmptyOnEmptyCache()
     func test_retrieve_hasNoSideEffectsOnEmptyCache()
     func test_retrieve_deliversFoundValuesOnNonEmptyCache()
     func test_retrieve_hasNoSideEffectsOnNonEmptyCache()

     func test_insert_overidesPrevioslyInsertedCache()

     func test_delete_hasNoSideEffectOnEmptyCache()
     func test_delete_emptiesPrevioslyInsertedCache()
 
     func test_sideEffectsAreSerial()
}

//these specs are not mandatory , they are specifications, we need to conform to basic protocol

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retieve_deliversFailureOnRetrievalError()
    func test_retieve_hasNoSideEffectsOnFailure()
}
protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectOnDeletionError()
}

//this is composition
typealias FailableFeedStoreSpecs = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
