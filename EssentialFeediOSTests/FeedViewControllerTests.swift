//
//  FeedViewControllerTestss.swift
//  EssentialFeediOSTests
//
//  Created by אליסה לשין on 07/09/2023.
//


/*
 
 [✅] Load feed automatically when view is presented
 func test_init_doesNotLoadFeed()
 func test_viewDidLoad_loadsFeed()
 
 [✅] Allow customer to manually reload feed (pull to refresh)
 func test_userInitiatedFeedReload_loadsFeed()
 
 [✅] Show a loading indicator while loading feed
 func test_viewDidLoad_showLoadingIndicator()
 # Hide a loading indicator while loading feed copleted
 func test_viewDidLoad_hideLoadingIndicatorOnLoaderCompletion()
 # Show loading indicator on pull to refresh
 func test_userInitiatedFeedReload_showsLoadingIndicator()
 # Hide a loading indicator on pull to refresh copleted
 func test_userInitiatedFeedReload_hidesLoadingIndicatorOnLoaderCompletion
 
 
 [ ] Render all loaded feed items (location, image, description)
 [ ] Image loading experience
 [ ] Load when image view is visible (on screen)
 [ ] Cancel when image view is out of screen
 [ ] Show a loading indicator while loading image (shimmer)
 [ ] Option to retry on image download error
 [ ] Preload when image view is near visible
 */

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
                
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
      
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        
        private var completions = [(FeedLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        func completeFeedLoading(at index: Int) {
            completions[index](.success([]))
        }
    }
}

private extension FeedViewController {
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
}
private extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}


