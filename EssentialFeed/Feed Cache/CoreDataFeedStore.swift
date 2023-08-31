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
         
    }
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
        let context = self.context
                context.perform {
                    do {
                        let managedCache = ManagedCache(context: context)
                        managedCache.timestamp = timestamp
                        managedCache.feed =  ManagedFeedImage.images(from: feed, in: context)
                        try context.save()
                        completion(nil)
                    } catch {
                        completion(error)
                    }
                }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        
        let context = self.context
        context.perform {

            do {

                let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
                request.returnsObjectsAsFaults = false
                if let cache = try context.fetch(request).first {
                    completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }

            } catch {
                completion(.failure(error))
            }
        }
    }
}

private extension NSPersistentContainer {
    
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistanceStore(Swift.Error)
    }
    
    static func load(modulName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        
        guard let model = NSManagedObjectModel.with(name: name, bundel: bundle) else {
            throw LoadingError.modelNotFound
        }
        var loadError: Swift.Error?
        
        let descroption = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [descroption]
        
        container.loadPersistentStores(completionHandler: { loadError = $1 })
        try loadError.map { error in
            throw LoadingError.failedToLoadPersistanceStore(error)
        }
        return container
    }
}

private extension NSManagedObjectModel {
    
    static func with(name: String, bundel: Bundle) -> NSManagedObjectModel? {
        
        return bundel
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

@objc(ManagedCache)
private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
    
    var localFeed: [LocalFeedImage] {
        return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
      }
}

@objc(ManagedFeedImage)
private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
    
    static func images(from feed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        
        return NSOrderedSet(array: feed.map { local in
            let managed = ManagedFeedImage(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.url = local.url
            return managed
        })
    }
    var local: LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
}
