//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by אליסה לשין on 18/12/2023.
//

import XCTest
import Combine
import UIKit
import EssentialFeed
import EssentialFeediOS
import EssentialApp


final class CommentsUIIntegrationTests: XCTestCase {
    
    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.title, commentsTitle)
    }
   
     func test_loadCommentsActions_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCommentsCallCount, 1)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3)
    }
    
    
     func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loading.")
        
        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully.")
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator,"Expected loading indicator once user initiated loading" )
        
        loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completed with error")
    }
    
     func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let comment0 = makeComment(message:"a message", username:"a username")
        let comment1 = makeComment(message: "another message", username:"another username")
         
        let empty = [ImageComment]()
        let (sut, loader) =  makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: empty)
        
        
        loader.completeCommentsLoading(with: [comment0],at: 0)
        assertThat(sut, isRendering: [comment0])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [comment0, comment1 ], at: 1)
        assertThat(sut, isRendering: [comment0, comment1 ])
    }
    
     func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
            let comment0 = makeComment()
 
            let (sut, loader) = makeSUT()

            sut.loadViewIfNeeded()
 
            loader.completeCommentsLoading(with: [comment0], at: 0)
            assertThat(sut, isRendering: [comment0])

            
            sut.simulateUserInitiatedReload()
            
            loader.completeCommentsLoading(with: [], at: 1)
           
            assertThat(sut, isRendering: [ImageComment]())
        }
 
     func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let comment = makeComment()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, isRendering: [comment])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [comment])
        
    }
    
     func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread()  {
        
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        let expectation = expectation(description: "Waiting for completion")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
     func test_loadCommentsCompletion_rendersErorMessageOnErrorUntilNextReload() {
        
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage,loadError)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
        
    }
    
    
     func test_tapOnErrorView_hidesErrorMessage() {
        
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage,loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
     func test_feedView_doesNotShowErrorMessageOnLoadingStart() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertNil(sut.errorMessage, "Error message expected to be not visible, instead \(String(describing: sut.errorMessage))")
    }

     func test_feedView_showsErrorMessageOnCompletionFailure() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertNotNil(sut.errorMessage, "Error message expected to be visible, instead no message")
    }
     func test_feedView_hasErrorMessageLocalized() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError, "Expected localized error explanation")
    }
    
     func test_feedView_hidesErrorMessageOnRefreshUntilNextFailure() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertNil(sut.errorMessage, "Error message expected to be not visible, instead \(String(describing: sut.errorMessage))")

        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateUserInitiatedReload()
        XCTAssertNil(sut.errorMessage, "Error message expected to be not visible, instead \(String(describing: sut.errorMessage))")
    }
    
     func test_feedView_hidesErrorMessageOnTap() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertNil(sut.errorMessage, "Error message expected to be not visible, instead \(String(describing: sut.errorMessage))")

        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)

        sut.simulateErrorViewTap()
        XCTAssertNil(sut.errorMessage, "Error message expected to be not visible, instead \(String(describing: sut.errorMessage))")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
       
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
   
    private func makeComment(message:String = "any message", username: String = "any user") -> ImageComment {
        return ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
     }
    
    private func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedComments(), comments.count, "comments count", file: file, line: line)
        
        let viewModel = ImageCommentsPresenter.map(comments)
        
            viewModel.comments.enumerated().forEach { index,comment in
            XCTAssertEqual(sut.commentMessage(at: index), comment.message, "message at \(index)", file: file, line: line)
            XCTAssertEqual(sut.commentDate(at: index), comment.date, "date at \(index)", file: file, line: line)
            XCTAssertEqual(sut.commentUsername(at: index), comment.username, "username at \(index)", file: file, line: line)
        }
    }
    
    private class LoaderSpy {
 
        private var requests = [PassthroughSubject<[ImageComment], Error>]()
        
        var loadCommentsCallCount: Int {
            return requests.count
        }
        
        func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            
            let publisher = PassthroughSubject<[ImageComment], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
       
        
        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
            requests[index].send(comments)
             
        }
        func completeCommentsLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            requests[index].send(completion: .failure(error))
        }
    }
}
