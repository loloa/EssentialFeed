//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 12/08/2023.
//

/* Important behavior to test
 
 1. RemoteFeedLoader did not load , so expected url of client is nil
 2. It is important to test that given the client URL is the same as expected
 3. How many times the client executes get(from: url), for this purpose we want HTTPClientSpy capture array of urls
 4. not delevered data connectivity error
 5.invalid data = not 200 status
 6. 200 but inavalid json
 7. 200 but empty json []/{}
 8. 200 + valid json
 9. test for memory leak addTeardownBlock{} 
 10. test if result was passed to callback if instanse of requester deallocated
 */

import XCTest

import EssentialFeed

final class FeedItemsMapperTest: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        
        let json = makeItemsJSON(items: [])
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach {  code in
 
            XCTAssertThrowsError(
            
                try FeedItemMapper.map(json, response: HTTPURLResponse(statusCode: code))
            )
            
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidJson() throws {
      
        let invalidJson =  Data("invalid json".utf8)
        
        XCTAssertThrowsError(
        
            try FeedItemMapper.map(invalidJson, response: HTTPURLResponse(statusCode: 200))
        )
    }
    
    
    func test_map_deliversItemsOn200HTTPResponseWithJSONItems() throws {
 
        
        let (item1, item1JSON) = makeItem(id: UUID(),
                             description: nil,
                             location: nil,
                             imageURL: URL(string: "https://a-url.com")!)
 
        let (item2, item2JSON) = makeItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "https://another-url.com")!)
        
        let json = makeItemsJSON(items: [item1JSON, item2JSON])
        
        let result = try FeedItemMapper.map(json, response: HTTPURLResponse(statusCode: 200))
 
        XCTAssertEqual(result, [item1, item2])
         
    }
    
    
    
    func test_map_deliversNoItemsOn200HTTPResponseWithEmtyJsonList() throws {
 
        
        let emptyListJSON = makeItemsJSON(items: [])
        
        let result = try FeedItemMapper.map(emptyListJSON, response: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [])
    }
   
    
    // MARK: - Helpers
    
    private func makeItemsJSON(items: [[String: Any]]) -> Data {
        
        let itemsJSON = ["items" : items]
 
        let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
        return json
    }
    private func makeItem(id: UUID, description: String?, location: String?, imageURL: URL) -> (model:FeedImage, json: [String: Any]){
        
        let item =  FeedImage(id: id, description: description, location: location, url: imageURL)
        
        let json = [
            "id"         : item.id.uuidString,
            "description": item.description,
            "location"   : item.location,
            "image"      : item.url.absoluteString
        ].compactMapValues{$0}
        
        return (item, json)
        
    }
    
 }

private extension HTTPURLResponse {
    
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
