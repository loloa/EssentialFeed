//
//  SharedLocalizationStrings.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 22/10/2023.
//

import XCTest
import EssentialFeed

final class SharedLocalizationTests: XCTestCase {
    
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalizedKeyAndValuesExists(in: bundle, table)
    }
    
    // MARK: - Helpers
    
    private class DummyView : ResourceView {
        func display(_ viewModel: Any) {
            
        }
    }
   
}
