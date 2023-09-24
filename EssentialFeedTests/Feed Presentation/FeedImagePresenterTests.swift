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
    private let imageTransformer: (Data) -> Any?
    
    init(view: FeedImageView, imageTransformer: @escaping (Data) -> Any?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    private struct InvalidImageDataError: Error {}
    
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
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        let viewModel = FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: image,
            isLoading: false,
            shouldRetry: false)
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
    
    func test_didFinishLoadingImageDataWithError_stopsLoaderDisplaysRetry() {
        
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
    
    func test_didFinishLoadingImageDataWithData_shoedRetryOnFailedImageTransformation() {
        
        let (sut, view) = makeSUT(imageTransformer: { _ in nil })
        let image = uniqueImage()
        let data = Data()
        sut.didFinishLoadingImageData(with: data, for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
        
    }
    //MARK: -
    
    private  class ViewSpy: FeedImageView {
        
        private(set) var messages = [FeedImageViewModel]()
        
        func display(_ model: FeedImageViewModel) {
            messages.append(model)
        }
    }
    
    private func makeSUT(
        imageTransformer: @escaping (Data) -> Any? = { _ in nil },
        file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter,view: ViewSpy) {
            
            let view = ViewSpy()
            let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
            trackForMemoryLeaks(view, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
            
            return (sut, view)
        }
}
