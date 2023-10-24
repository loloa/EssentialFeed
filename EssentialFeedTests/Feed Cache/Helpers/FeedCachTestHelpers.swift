//
//  FeedCachTestHelpers.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 21/08/2023.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: nil, location: nil, url: anyURL())
}
func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map{ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    return (models, local)
}
 
extension Date {
    private var feedCacheMaxAge: Int {
        return 7
    }
    func minusFeedCacheMaxAge() -> Date {
        return self.adding(days: -feedCacheMaxAge)
    }
 
}



