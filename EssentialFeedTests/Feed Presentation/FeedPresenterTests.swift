//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 21/09/2023.
//

import XCTest

final class FeedPresenter {
    
    init(view: Any) {
        
    }
}
final class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty, "Expected not view messages")
    }

    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedPresenter, ViewSpy) {
        let view  = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
        
    }
    private class ViewSpy {
        let messages = [Any]()
    }
}
