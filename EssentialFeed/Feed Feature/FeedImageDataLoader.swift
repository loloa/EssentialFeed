//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 12/09/2023.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
 
    func loadImageData(from url: URL) throws -> Data
}
