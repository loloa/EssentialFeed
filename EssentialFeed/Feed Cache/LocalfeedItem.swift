//
//  LocalfeedItem.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 17/08/2023.
//

import Foundation

// Data transfer Objects /Mirro
public struct LocalFeedItem: Equatable {
    
   public let id: UUID
   public let description: String?
   public let location: String?
   public let imageURL: URL
    

    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
