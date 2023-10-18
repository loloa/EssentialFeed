//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 17/10/2023.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    
    convenience init (url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
    }
}
/*
public final class RemoteImageCommentsLoader {
 
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        
        case connectivity
        case invalidData
    }
   
    
    public typealias Result = Swift.Result<[ImageComment], Swift.Error>
    
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
                
            case let .success((data, response)):
                completion(RemoteImageCommentsLoader.map(data, from: response))
             case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        
        do {
            let items = try ImageCommentsMapper.map(data, response: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}

 */
