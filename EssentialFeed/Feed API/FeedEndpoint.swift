//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 04/02/2024.
//

import Foundation

public enum FeedEndpoint {
    
    case get
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appending(path: "/v1/feed")
        }
    }
}
