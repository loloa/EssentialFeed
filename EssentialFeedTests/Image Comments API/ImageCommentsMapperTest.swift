//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 17/10/2023.
//

import XCTest
import EssentialFeed

final class ImageCommentsMapperTest: XCTestCase {
 
    
    func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
        
        let json = makeItemsJSON(items: [])
        
        let samples = [199, 150, 300, 400, 500]
        
        try samples.forEach { code in
            
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(json, response: HTTPURLResponse(statusCode: code))
            )
         }
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJson() throws {
        
        let invalidJson =  Data("invalid json".utf8)
        
        let samples = [200, 210, 250, 280, 299]
        
        try samples.forEach { code in
            
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(invalidJson, response: HTTPURLResponse(statusCode: code))
            )
         }
     }
    
    
    func test_map_deliversItemsOn2xxHTTPResponseWithJSONItems() throws {
 
        let item1 = makeItem(
                    id: UUID(),
                    message: "a message",
                    createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
                    username: "a username")
                
                let item2 = makeItem(
                    id: UUID(),
                    message: "another message",
                    createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
                    username: "another username")
                
                let items = [item1.model, item2.model]
 
        let json = makeItemsJSON(items: [item1.json, item2.json])
 
        let samples = [200, 210, 250, 280, 299]
        
        try samples.forEach { code in
            
            let result = try ImageCommentsMapper.map(json, response: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, items)
         }
     }
    
    
    
    func test_map_deliversNoItemsOn2xxHTTPResponseWithEmtyJsonList() throws {
 
        let emptyListJSON = makeItemsJSON(items: [])
        let samples = [200, 210, 250, 280, 299]
        
        try samples.enumerated().forEach { index, code in
            
            let result = try ImageCommentsMapper.map(emptyListJSON, response: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [])
             
        }
    }
 
    
    // MARK: - Helpers
 
    ////ISO8601DateFormatter().string(from: createdAt)
    ///
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model:ImageComment, json: [String: Any]){
        
        let item =  ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        
        let json: [String: Any] = [
            "id"         : id.uuidString,
            "message": message,
            "created_at"   : createdAt.iso8601String,
            "author"      : [
                "username" : username
            ]
        ]
        
        return (item, json)
    }
}

