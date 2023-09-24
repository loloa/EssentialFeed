//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 24/09/2023.
//

import XCTest
import EssentialFeed


struct FeedImageViewModel {
    let description: String?
    let location: String?
    let image: Any?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
protocol FeedImageView {
    func display(_ model: FeedImageViewModel)
}

class FeedImagePresenter {
    
    private let view: FeedImageView
    
    init(view: FeedImageView) {
        self.view = view
    }
    func didStartLoadingImageData(for model: FeedImage) {
        
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        let viewModel: FeedImageViewModel = FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: false,
            shouldRetry: true)
        view.display(viewModel)
    }
}

final class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessageToView(){
        
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages")
    }
    
    func test_didStartLoadingImageData_displayLoader() {
        
        let (sut, view) = makeSUT()
        let image = uniqueImage()
        sut.didStartLoadingImageData(for: image)
        let model = view.messages.first
        
        XCTAssertEqual(model?.description, image.description)
        XCTAssertEqual(model?.location, image.location)
        XCTAssertNil(model?.image)
        XCTAssertEqual(model?.isLoading, true)
        XCTAssertEqual(model?.shouldRetry, false)
 
    }
    
    func test_didFinishLoadingImageDataWithError() {
        
        let (sut, view) = makeSUT()
        let image = uniqueImage()
        sut.didFinishLoadingImageData(with: anyNSError(), for: image)
        
        let model = view.messages.first
        
        XCTAssertEqual(model?.description, image.description)
        XCTAssertEqual(model?.location, image.location)
        XCTAssertNil(model?.image)
        XCTAssertEqual(model?.isLoading, false)
        XCTAssertEqual(model?.shouldRetry, true)
    }
    
    //MARK: -
    
    private  class ViewSpy: FeedImageView {
        
       private(set) var messages = [FeedImageViewModel]()
        
        func display(_ model: FeedImageViewModel) {
             messages.append(model)
        }
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter,view: ViewSpy) {
        
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, view)
    }
}
