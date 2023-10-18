//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 17/10/2023.
//

import Foundation


public final class ImageCommentsMapper {
   
   private struct Root: Decodable {
       private let items: [Item]
       
       private struct Item: Decodable {
           
           let id: UUID
           let message: String
           let created_at: Date
           let author: Author
       }
       private struct Author: Decodable {
           
           let username: String
       }
       
       var comments: [ImageComment] {
           
           items.map{ ImageComment(id: $0.id, message: $0.message, createdAt: $0.created_at, username: $0.author.username)}
       }
   }
  
   //used by FeedItemLoader, has to be , accessable in the module
    
    public enum Error: Swift.Error {
        case invalidData
    }
   
   public static func map(_ data: Data, response: HTTPURLResponse) throws -> [ImageComment] {

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard isOk(response),
              let root = try? decoder.decode(Root.self, from: data) else {
            throw Error.invalidData
        }
       return root.comments
   }
    
    private static func isOk(_ response: HTTPURLResponse) -> Bool {
        
        return (200...299).contains(response.statusCode)
    }
  
}

