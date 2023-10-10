//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by אליסה לשין on 10/10/2023.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class FeedSnapShotTests: XCTestCase {
    
    func test_emptyFeed() {
        
        let sut = makeSUT()
        sut.display(emptyFeed())
        let snapshot = sut.snapshot()
        record(snapshot: snapshot, named: "EMPTY_FEED")
    }
    
    func test_feedWithContent() {
        
        let sut = makeSUT()
        sut.display(feedWithContent())
        let snapshot = sut.snapshot()
        record(snapshot: snapshot, named: "FEED_WITH_CONTENT")
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
    
    private func feedWithContent() -> [ImageStub] {
        
        return [
                    ImageStub(
                        description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                        location: "East Side Gallery\nMemorial in Berlin, Germany",
                        image: UIImage.make(withColor: .red)
                    ),
                    ImageStub(
                        description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                        location: "Garth Pier",
                        image: UIImage.make(withColor: .green)
                    )
                ]
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

private extension FeedViewController {
    
    func display(_ stabs: [ImageStub]) {
        let cells: [FeedImageCellController] = stabs.map { stub in
            let cellController = FeedImageCellController(delegate:  stub)
            stub.controller = cellController
            return cellController
        }
        
        display(cells)
    }
}
private class ImageStub: FeedImageCellControllerDelegate  {
    
    let viewModel: FeedImageViewModel<UIImage>
    weak var controller: FeedImageCellController?
    
    init(description: String?, location: String?, image: UIImage?) {
         viewModel = FeedImageViewModel(
            description: description,
            location: location,
            image: image,
            isLoading: false,
            shouldRetry: image == nil)
    }
    
    func didRequestImage() {
        controller?.display(viewModel)
    }
    
    func didCancelImageRequest() {
         
    }
    
    
    
}
