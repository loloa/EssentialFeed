//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialAppTests
//
//  Created by אליסה לשין on 03/10/2023.
//

import XCTest

extension XCTestCase  {
    
     func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
 }
