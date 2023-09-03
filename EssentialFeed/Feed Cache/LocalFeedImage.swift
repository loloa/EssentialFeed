//
//  LocalfeedItem.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 17/08/2023.
//

import Foundation

// Data transfer Objects /Mirro from backend object
/*
 we added Codable = details of framework FileSystem to the LocalFeedImage which is in the framework agnostic area, it is not right
 if we will use CoreData instead of filesystem, so Core Data does not need these Codable capability
 */
public struct LocalFeedImage: Equatable {
    
   public let id: UUID
   public let description: String?
   public let location: String?
   public let url: URL
    

    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
