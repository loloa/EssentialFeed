//
//  CoreDataHelpers.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 31/08/2023.
//

import CoreData

 extension NSPersistentContainer {
    
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
