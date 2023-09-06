//
//  RemoteFedItem.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 17/08/2023.
//

import Foundation


 struct RemoteFeedItem: Decodable {
    
     let id: UUID
     let description: String?
     let location: String?
     let image: URL
 
}
