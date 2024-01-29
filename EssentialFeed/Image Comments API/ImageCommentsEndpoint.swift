//
//  ImageCommentsEndpoint.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 26/12/2023.
//

import Foundation

public enum ImageCommentsEndPoints {
    
    case get(UUID)
    //case post(ImageComment)
    
    public func url(baseURL: URL) -> URL {
        
        switch self {
        case let .get(id):
            return baseURL.appending(path: "/v1/image/\(id)/comments")
            
        }
    }
}
