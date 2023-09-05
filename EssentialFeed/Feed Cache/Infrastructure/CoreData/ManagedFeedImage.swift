//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 31/08/2023.
//

import CoreData

@objc(ManagedFeedImage)
 class ManagedFeedImage: NSManagedObject {
   @NSManaged var id: UUID
   @NSManaged var imageDescription: String?
   @NSManaged var location: String?
   @NSManaged var url: URL
   @NSManaged var cache: ManagedCache
 
   var local: LocalFeedImage {
       return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
   }
}

extension ManagedFeedImage {
    
     static func images(from feed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        
        return NSOrderedSet(array: feed.map { local in
            let managed = ManagedFeedImage(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.url = local.url
            //just try to use adding to prev commit
            return managed
        })
    }
}
