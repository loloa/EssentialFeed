//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 17/10/2023.
//

import Foundation


final class ImageCommentsMapper {
   
   private struct Root: Decodable {
       let items: [RemoteFeedItem]
   }
  
   //used by FeedItemLoader, has to be , accessable in the module
   
    static func map(_ data: Data, response: HTTPURLResponse) throws -> [RemoteFeedItem] {

        guard isOk(response),
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }
       return root.items
   }
    
    private static func isOk(_ response: HTTPURLResponse) -> Bool {
        
        return (200...299).contains(response.statusCode)
    }
  
}

