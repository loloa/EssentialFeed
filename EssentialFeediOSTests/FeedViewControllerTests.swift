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
 
 
 [] Allow customer to manually reload feed (pull to refresh)
 [] Show a loading indicator while loading feed
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

final class FeedViewController: UITableViewController {
    
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    
    @objc private func load() {
        loader?.load(completion: { _ in
            
        })
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    
    
    func test_pullToRefresh_loadsFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.refreshControl?.simulatePullRefresh()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.refreshControl?.simulatePullRefresh()
        XCTAssertEqual(loader.loadCallCount, 3)
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
        private(set) var loadCallCount: Int = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }
}

private extension UIRefreshControl {
    
    func simulatePullRefresh() {
        
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
