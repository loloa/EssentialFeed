//
//  CoreDataFeedStore.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 30/08/2023.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try! NSPersistentContainer.load(modulName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
        perform { context in
            
            completion(Result(catching: {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            }))
            
        }
    }
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
        perform { context in
            
            completion(Result(catching: {
//
//                let managedCache = try ManagedCache.newUniqueInstance(in: context)
//                managedCache.timestamp = timestamp
//                managedCache.feed =  ManagedFeedImage.images(from: feed, in: context)
//                try context.save()
                
               //HELP!
                do {
                    let managedCache = try ManagedCache.newUniqueInstance(in: context)
                    managedCache.timestamp = timestamp
                    managedCache.feed =  ManagedFeedImage.images(from: feed, in: context)
                    try context.save()
                    completion(.success())
                }catch {
                    context.rollback()
                    completion(.failure(error))
                }
 
            }))
             
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        
        perform { context in
            
            completion(Result(catching: {
                try ManagedCache.find(in: context).map {
                    return (CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp))
                }
            }))
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform {  action(context) }
    }
}

