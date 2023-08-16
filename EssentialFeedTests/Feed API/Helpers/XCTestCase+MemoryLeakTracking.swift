//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 09/08/2023.
//

import XCTest

extension XCTestCase {
    
     func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been dealocated. Potencial memory leak.", file: file, line: line)
        }
    }
}
