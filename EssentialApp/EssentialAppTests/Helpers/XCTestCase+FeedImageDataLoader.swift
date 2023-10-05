//
//  XCTestCase+FeedImageDataLoader.swift
//  EssentialAppTests
//
//  Created by אליסה לשין on 05/10/2023.
//

import XCTest
import EssentialFeed

protocol FeedImageDataLoaderTestCase: XCTestCase {}

extension FeedImageDataLoaderTestCase {
    
    func expect(_ sut: FeedImageDataLoader, completeWith expectedResult: FeedImageDataLoader.Result, action:() -> Void,  file: StaticString = #file, line: UInt = #line ) {
        
        let exp = expectation(description: "Waiting for completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            
            switch (expectedResult,receivedResult) {
                
            case let (.success(expectedData), .success(recevedData)):
                XCTAssertEqual(expectedData, recevedData, "Expected \(expectedData), instead got \(recevedData)", file: file, line: line)
            case (.failure , .failure):
                break
            default:
                XCTFail("Expected successfull load data, instead gor \(receivedResult)", file: file, line: line)
                
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
 
}
