//
//  FeedUIIntegrationTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by אליסה לשין on 18/09/2023.
//

import Foundation
import XCTest
import EssentialFeed

//DSL protected test

extension FeedUIIntegrationTests {
    
    private class DummyView: ResourceView {
        
        func display(_ viewModel: Any) {
            
        }
    }
    var loadError:String {
        LoadResourcePresenter<Any, DummyView>.loadError
    }
    
    var feedTitle: String {
        FeedPresenter.title
    }
    
    var commentsTitle: String {
        ImageCommentsPresenter.title
    }
//    func localized(_ key: String, table: String = "Feed", file: StaticString = #file, line: UInt = #line) -> String {
//         
//        let bundle = Bundle(for: FeedPresenter.self)
//        let value = bundle.localizedString(forKey: key, value: nil, table: table)
//        if value == key {
//            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
//        }
//        return value
//    }
}
