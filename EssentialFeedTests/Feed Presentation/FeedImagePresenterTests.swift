//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 24/09/2023.
//

import XCTest
import EssentialFeed


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
    
//    func test_didFinishLoadingImageDataWithError_stopsLoaderDisplaysRetry() {
//        
//        let (sut, view) = makeSUT()
//        let image = uniqueImage()
//        sut.didFinishLoadingImageData(with: anyNSError(), for: image)
//        
//        let model = view.messages.first
//        
//        XCTAssertEqual(model?.description, image.description)
//        XCTAssertEqual(model?.location, image.location)
//        XCTAssertNil(model?.image)
//        XCTAssertEqual(model?.isLoading, false)
//        XCTAssertEqual(model?.shouldRetry, true)
//    }
    
    func test_didFinishLoadingImageDataWithData_displaysRetryOnFailedImageTransformation() {
        
        let (sut, view) = makeSUT(imageTransformer: fail)
        let image = uniqueImage()
       
        sut.didFinishLoadingImageData(with: Data(), for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
        
    }
    
    func test_didFinishLoadingImageDataWithData_displaysImageOnSuccessfullTransformation() {
        
        let image = uniqueImage()
        let data = Data()
        let transformedData = AnyImage()
        let (sut, view) = makeSUT { _ in
            transformedData
        }
        
        sut.didFinishLoadingImageData(with: data, for: image)
        
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.image, transformedData)
        
    }
    //MARK: -
    private struct AnyImage: Equatable {}
    private var fail: (Data) -> AnyImage? {
            return { _ in nil }
        }
    
    private func makeSUT(
        imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil },
        file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>,view: ViewSpy) {
            
            let view = ViewSpy()
            let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
            trackForMemoryLeaks(view, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
            
            return (sut, view)
        }
    
    private  class ViewSpy: FeedImageView {
        
        private(set) var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ model: FeedImageViewModel<AnyImage>) {
            messages.append(model)
        }
    }
   
}
