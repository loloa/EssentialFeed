//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 24/10/2023.
//

import XCTest
import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        
        assertLocalizedKeyAndValuesExists(in: bundle, table)
     }
 
}
