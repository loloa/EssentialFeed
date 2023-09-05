//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 07/08/2023.
//

import Foundation

 
 final class FeedItemMapper {
    
    private struct Root: Decodable {
        
        let items: [RemoteFeedItem]
         
    }

   
    private static var OK_200: Int {return 200}
    
    //used by FeedItemLoader, has to be , accessable in the module
    
    
     static func map(_ data: Data, response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data)else {
            throw RemoteFeedLoader.Error.invalidData
        }
       
        return root.items
    }
   
}

