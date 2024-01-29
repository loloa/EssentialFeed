//
//  ListSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by אליסה לשין on 25/10/2023.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class ListSnapshotTests: XCTestCase {

    func test_emptyList() {
        
        let sut = makeSUT()
        sut.display(emptyList())
        
//        record(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "EMPTY_LIST_light")
//        record(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "EMPTY_LIST_dark")
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "EMPTY_LIST_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "EMPTY_LIST_dark")

    }
    
    func test_listWithErrorMessage() {
        
        let sut = makeSUT()
        sut.display(.error(message: "An error message\n multiline error \n message"))
        
//        record(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LIST_WITH_ERROR_MESSAGE_light")
//        record(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LIST_WITH_ERROR_MESSAGE_dark")
//        record(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "LIST_WITH_ERROR_MESSAGE_light_extraExtraExtraLarge")
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LIST_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LIST_WITH_ERROR_MESSAGE_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "LIST_WITH_ERROR_MESSAGE_light_extraExtraExtraLarge")
    }
    
    
    //MARK: -
    
    private func makeSUT() -> ListViewController {
//        let bundle = Bundle(for: ListViewController.self)
//        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
//        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        let controller = ListViewController()
        controller.tableView.separatorStyle = .none
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        controller.loadViewIfNeeded()
        return controller
    }
    
    private func emptyList() -> [CellControler] {
        return []
    }
}
