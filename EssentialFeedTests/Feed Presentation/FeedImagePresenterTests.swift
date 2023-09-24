//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 24/09/2023.
//

import XCTest

class FeedImagePresenter {
    
    init(view: Any) {
         
    }
}

final class FeedImagePresenterTests: XCTestCase {

    func test_init_doesNotSendMessageToView(){
        
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages")
    }

 
    //MARK: -
    
    private  class ViewSpy {
        let messages = [Any]()
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter,view: ViewSpy) {
        
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, view)
    }
}
