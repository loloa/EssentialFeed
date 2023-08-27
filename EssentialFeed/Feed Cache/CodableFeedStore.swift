//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 26/08/2023.
//

import Foundation

public class CodableFeedStore: FeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let  timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map{ $0.local }
        }
    }
    //"Make it work. Make it right. Make it fast. In that order."—Kent Beck
    
    private struct CodableFeedImage: Codable {
        /* priority to decoupling, but if you think it hurts the performance , need to mesure before optimizing */
        
        /*
         
         We encourage you to measure your test suite performance over time. It should be automated, as part of your CI reports. Performance outliers should alert you to take action before they become a costly problem.
         
         To measure our test suite times, we used the following xcodebuild command to clean, build and test the EssentialFeed project using the EssentialFeed scheme:
         
         xcodebuild clean build test -project EssentialFeed/EssentialFeed.xcodeproj -scheme "EssentialFeed"
         */
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    private let storeURL: URL
    private let backGroundQueu = DispatchQueue(label: "\(CodableFeedStore.self)Queu", qos: .userInitiated, attributes: .concurrent)
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    /*
     retrieve has no side effects, it can run concurrently!!!!
     we can add attribute to queue .concurrent and ad flag .barrier to the operations that run concurrently (have side effects)
     
     in this block there is no retaincycle but we avoid to use self to prevent holding the reference to object when it is unnessary, we prevent the object from deallocation when it is not needed
     performance issues and runtime erors
     */
    public func retrieve(completion: @escaping RetrievalCompletion) {
        
        let storeURL = self.storeURL
        backGroundQueu.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }
            
            do {
                
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
            } catch {
                completion(.failure(error))
            }
        }
     }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion){
        let storeURL = self.storeURL
        backGroundQueu.async (flags: .barrier) {
            do {
                
                let encoder = JSONEncoder()
                //let cache = Cache(feed: feed.map{ CodableFeedImage($0)}, timestamp: timestamp)
                let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
            
        }
    }
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        
        backGroundQueu.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
     }
}
