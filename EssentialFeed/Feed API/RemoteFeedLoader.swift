//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 12/08/2023.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
 
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        
        case connectivity
        case invalidData
    }
   
    //we dont want expose this implementation detail to higher- level Feed feature module
    public typealias Result = FeedLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    //this is main behaviour, so has to be public too
    public func load(completion: @escaping (Result) -> Void) {
        
        client.get(from: url) { [weak self] result in
            
            //this prevents unexpected behavior when instance deallocated
            guard self != nil else {return}
            
            switch result {
                
            case let .success(data, response):
                completion(RemoteFeedLoader.map(data, from: response))
             case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        
        do {
            let items = try FeedItemMapper.map(data, response: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map{ FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)}
    }
}

