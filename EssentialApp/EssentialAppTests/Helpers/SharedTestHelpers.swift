//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by אליסה לשין on 03/10/2023.
//

import Foundation
import EssentialFeed
 

 func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}
 func anyData() -> Data {
    return  Data("any-data".utf8)
}
 func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}
func uniqueFeed() -> [FeedImage] {
    return [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http://any-url.com")!)]
}
