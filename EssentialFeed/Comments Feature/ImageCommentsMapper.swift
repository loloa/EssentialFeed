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

        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }
       return root.items
   }
  
}

