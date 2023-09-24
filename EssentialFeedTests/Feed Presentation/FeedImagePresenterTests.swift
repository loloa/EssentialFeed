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
        
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages")
    }

    private  class ViewSpy {
        let messages = [Any]()
    }
}
