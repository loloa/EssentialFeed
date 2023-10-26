//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by אליסה לשין on 25/10/2023.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class ImageCommentsSnapshotTests: XCTestCase {

    func test_listWithComments() {
        
        let sut = makeSUT()
        sut.display(comments())
 
//        record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_LIGHT")
//        record(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_DARK")
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_DARK")
    }
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        controller.loadViewIfNeeded()
        return controller
    }
 
    private func comments() -> [CellControler] {
        commentsControllers().map{ CellControler($0)}
    }
    
    private func commentsControllers() -> [ImageCommentCellController] {
        
        return [
            
            ImageCommentCellController(
                model: ImageCommentViewModel(
                message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                date: "1000 yesrs ago",
                username: "a very long long long username")),
            
            ImageCommentCellController(
                model: ImageCommentViewModel(
                message: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                date: "10 days ago",
                username: "a username")),
            
            ImageCommentCellController(
                model: ImageCommentViewModel(
                message: "nice",
                date: "1 hour ago",
                username: "a."))
               
        ]
    }
}
