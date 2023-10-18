//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 07/08/2023.
//

import Foundation

 
public final class FeedItemMapper {
    
    private struct Root: Decodable {
        
       private let items: [RemoteFeedItem]
        
        
       private struct RemoteFeedItem: Decodable {
           
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
        
       }
        
        var images: [FeedImage] {
            items.map{ FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)}
        }
    }
   
    //used by FeedItemLoader, has to be , accessable in the module
    
   public static func map(_ data: Data, response: HTTPURLResponse) throws -> [FeedImage] {
 
         guard response.isOK,
               let root = try? JSONDecoder().decode(Root.self, from: data) else {
             throw RemoteFeedLoader.Error.invalidData
         }
         return root.images
    }
 }


