//
//  XCTest+Feedloader.swift
//  EssentialAppTests
//
//  Created by אליסה לשין on 04/10/2023.
//

import XCTest
import EssentialFeed


//class inheritence is not composable, so we could not inherit aditional behavior
//class FeedLoaderTestCase: XCTestCase {}

//this way exposes the method for all XCTestCase, valiates ISP
//extension XCTestCase {
protocol FeedLoaderTestCase: XCTestCase {}
 
extension FeedLoaderTestCase {
   /*
    
     func expect(_ sut: FeedLoader, completeWith expectedResult: Swift.Result<[FeedImage], Error>, file: StaticString = #file, line: UInt = #line) {
        
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected successful load feed result, instead got \(expectedResult)}", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
*/
}
