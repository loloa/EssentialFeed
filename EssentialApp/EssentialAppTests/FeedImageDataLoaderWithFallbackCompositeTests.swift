//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by אליסה לשין on 03/10/2023.
//


import XCTest
import EssentialFeed
import EssentialApp

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase, FeedImageDataLoaderTestCase {
    
    
    func test_doesNotDeliverImageDataIfLoadImageDataMethodNotCalled() {
        
        let (_, primaryLoader, fallbackLoader) = makeSUT()
        
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty)
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty)
        
    }
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        _ = sut.loadImageData(from: anyURL()) { _ in
            
        }
        
        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
        
    }
    
    func test_loadImageData_loadsFromFallbackOnPrimaryLoaderFailure() {
        
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        _ = sut.loadImageData(from: anyURL()) { _ in
            
        }
        
        primaryLoader.complete(with: anyNSError())
        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected failure on loading URL from primary loader")
        XCTAssertEqual(fallbackLoader.loadedURLs, [url], "Expected to load URL from fallback loader")
    }
    
    func test_cancelLoadImageData_cancelsPrimaryLoaderTask() {
        
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        let task = sut.loadImageData(from: anyURL()) { _ in }
        
        task.cancel()
        XCTAssertEqual(primaryLoader.cancelledURLs, [url])
        XCTAssertTrue(fallbackLoader.cancelledURLs.isEmpty)
    }
    func test_loadImageData_cancelFallback() {
        
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        let task = sut.loadImageData(from: anyURL()) { _ in }
        
        primaryLoader.complete(with: anyNSError())
        task.cancel()
        XCTAssertTrue(primaryLoader.cancelledURLs.isEmpty, "Expected no cancelled URLs in the primary loader")
        XCTAssertEqual(fallbackLoader.cancelledURLs, [url], "Expected to cancel URL loading from fallback loader")
        
    }
    func test_loadImageData_deliversDataOnPrimarySuccess() {
        
        let primaryData = anyData()
        let expectedResult: FeedImageDataLoader.Result = .success(primaryData)
        
        let (sut, primaryLoader, _) = makeSUT()
        
        expect(sut, completeWith: expectedResult) {
            primaryLoader.complete(with: primaryData)
        }
    }
    
    func test_loadImageData_deliversFallbackOnFallbackSuccess() {
        
        let fallbackData = anyData()
        let expectedResult: FeedImageDataLoader.Result = .success(fallbackData)
        
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        expect(sut, completeWith: expectedResult) {
            
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: fallbackData)
        }
    }
    
    func test_loadImageData_deliversErrorOnBothFailurePrimaryAndFallbackLoader() {
        
        let expectedResult: FeedImageDataLoader.Result = .failure(anyNSError())
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        expect(sut, completeWith: expectedResult) {
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: anyNSError())
        }
    }
    
    //MARK: - private
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, primary: FeedImageDataLoaderSpy, fallback: FeedImageDataLoaderSpy) {
        
        let primaryLoader = FeedImageDataLoaderSpy()
        let fallbackLoader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }
 
}
