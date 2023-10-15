//
//  SceneDelegateTests.swift
//  EssentialAppUIAcceptenceTests
//
//  Created by אליסה לשין on 08/10/2023.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

class SceneDelegateTests: XCTestCase {
    
    private class UIWindowSpy: UIWindow {
      var makeKeyAndVisibleCallCount = 0
      override func makeKeyAndVisible() {
        makeKeyAndVisibleCallCount = 1
      }
    }
    
    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let window = UIWindowSpy()
       
        let sut = SceneDelegate()
        sut.window = window

        sut.configureWindow()
        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1, "Expected to make window key and visible")

//        XCTAssertTrue(window.isKeyWindow, "Expected window to be the key window")
//        XCTAssertFalse(window.isHidden, "Expected window to be visible")
    }

    
    func test_configureWindowc_configuresRootViewController() {
            let sut = SceneDelegate()
            sut.window = UIWindow()

            sut.configureWindow()

            let root = sut.window?.rootViewController
            let rootNavigation = root as? UINavigationController
            let topController = rootNavigation?.topViewController

            XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
            XCTAssertTrue(topController is FeedViewController, "Expected a feed controller as top view controller, got \(String(describing: topController)) instead")
        }
}
