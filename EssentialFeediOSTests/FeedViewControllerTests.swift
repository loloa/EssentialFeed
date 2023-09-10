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
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description:"a description", location:"a location")
        let image1 = makeImage(description:nil, location:"another location")
        let image2 = makeImage(description:"another description", location:nil)
        let image3 = makeImage(description:nil, location: nil)
        
        let (sut, loader) =  makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        
        loader.completeFeedLoading(with: [image0],at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead.")
        }
        feed.enumerated().forEach { index, image in
             assertThat(sut, hasViewConfiguredFor: image, at: index)
        }
        
    }
    private func assertThat(
        _ sut: FeedViewController,
        hasViewConfiguredFor image: FeedImage,
        at index: Int,
        file: StaticString = #file,
        line: UInt = #line) {
        
        let view = sut.feedImageView(at: index)
            guard let cell = view as? FeedImageCell else {
                return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
            }
 
        let shouldLocationBeVisible = (image.location != nil)
            
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible,"Expected `shouldLocationBeVisible` to be \(shouldLocationBeVisible), for image view at index \(index), got \(String(describing: view))", file: file, line: line)
            XCTAssertEqual(cell.locationText, image.location,"Expected location text to be \(String(describing: image.location)) for image view at index = \(index)", file: file, line: line)
            
        XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index = \(index)", file: file, line: line)
    }
    
    private func makeImage(description:String? = nil, location: String? = nil, url: URL = URL(string: "http://-any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    class LoaderSpy: FeedLoader {
        
        private var completions = [(FeedLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            return completions.count
        }
 
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int) {
            completions[index](.success(feed))
        }
    }
}

private extension FeedImageCell {
    
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    var locationText: String? {
        return locationLabel.text
    }
    var descriptionText: String? {
        return descriptionLabel.text
    }
}
private extension FeedViewController {
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
     func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }
    private var feedImageSection: Int {
        return 0
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: index)
        
    }
}
private extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        
        //sendActions(for: .valueChanged)
         
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0), with: nil)
            }
        }
    }
}


