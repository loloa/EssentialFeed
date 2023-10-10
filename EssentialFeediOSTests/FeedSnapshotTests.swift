//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by אליסה לשין on 10/10/2023.
//

import XCTest
import EssentialFeediOS
 

class FeedSnapShotTests: XCTestCase {
    
    func test_emptyFeed() {
        
        let sut = makeSUT()
        sut.display(emptyFeed())
        let snapshot = sut.snapshot()
        record(snapshot: snapshot, named: "EMPTY_FEED")
    }
    
    //MARK: -
    
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        return []
    }
    private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
       
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot")
            return
        }
        
        // Users/alisala/Desktop/PracticeApps/EssentialFeed/EssentialFeediOSTests/FeedSnapshotTests.swift
        // Users/alisala/Desktop/PracticeApps/EssentialFeed/EssentialFeediOSTests/snapshots
        // Users/alisala/Desktop/PracticeApps/EssentialFeed/EssentialFeediOSTests/snapshots/EMPTY_FEED.png
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent().appending(component: "snapshots")
            .appending(component: "\(name).png")
        
        do {
            try FileManager.default
                .createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
        
    }
 
}

extension UIViewController {
    
    func snapshot() -> UIImage {
        
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}
