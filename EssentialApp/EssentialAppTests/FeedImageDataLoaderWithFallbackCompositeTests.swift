//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by אליסה לשין on 03/10/2023.
//


import XCTest
import EssentialFeed
import EssentialApp

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    
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
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, primary: LoaderSpy, fallback: LoaderSpy) {
        
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }
 
    
    private func expect(_ sut: FeedImageDataLoader, completeWith expectedResult: FeedImageDataLoader.Result, action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Waiting for completion")
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            
            switch (expectedResult, receivedResult) {
                
            case let (.success(expectedData), .success(receivedData)):
                XCTAssertEqual(expectedData, receivedData)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
            }
            
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        var cancelledURLs = [URL]()
        
        var loadedURLs: [URL] {
            return messages.map{ $0.url }
        }
        private struct Task: FeedImageDataLoaderTask {
            let cancellCallback: () -> Void
            func cancel() { cancellCallback() }
            
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            
            messages.append((url, completion))
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
        
        func complete(with error: NSError, at index: Int = 0){
            messages[index].completion(.failure(error))
        }
        
        func complete(with data: Data, at index: Int = 0) {
            messages[index].completion(.success(data))
        }
    }
   
}
