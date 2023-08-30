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
    
    public init(bundle: Bundle = .main) throws {
        container = try! NSPersistentContainer.load(modulName: "FeedStore", in: bundle)
         
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
         
    }
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
         
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
 }

private extension NSPersistentContainer {
    
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistanceStore(Swift.Error)
    }
    
    static func load(modulName name: String, in bundle: Bundle) throws -> NSPersistentContainer {
        
        guard let model = NSManagedObjectModel.with(name: name, bundel: bundle) else {
            throw LoadingError.modelNotFound
        }
        var loadError: Swift.Error?
        
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
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

private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}
