//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 17/10/2023.
//

import XCTest
import EssentialFeed

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
 
    
    func test_load_deliversErrorOnNon2xxHTTPResponse() {
        
        let (sut, client) = makeSUT()
        
        let samples = [199, 150, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let json = makeItemsJSON(items: [])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJson() {
        
        let (sut, client) = makeSUT()
        
        let samples = [200, 210, 250, 280, 299]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                
                let invalidJson =  Data("invalid json".utf8)
                client.complete(withStatusCode: code, data: invalidJson, at: index)
            }
        }
       
    }
    
    
    func test_load_deliversItemsOn2xxHTTPResponseWithJSONItems(){
        
        let (sut, client) = makeSUT()
        
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
 
        
        let samples = [200, 210, 250, 280, 299]
        
        samples.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: .success(items), when: {
                
                let json = makeItemsJSON(items: [item1.json, item2.json])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
 
    }
    
    
    
    func test_load_deliversErrorOn2xxHTTPResponseWithEmtyJsonList() {
        
        let (sut, client) = makeSUT()
        
        
        let samples = [200, 210, 250, 280, 299]
        
        samples.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: .success([])) {
                
                let emptyListJSON = makeItemsJSON(items: [])
                client.complete(withStatusCode: code, data: emptyListJSON, at: index)
            }
        }
    }
 
    
    // MARK: - Helpers
    
    private func makeItemsJSON(items: [[String: Any]]) -> Data {
        
        let itemsJSON = ["items" : items]
 
        let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
        return json
    }
    
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
    
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        
        return .failure(error)
    }
    
    private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
 
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            
            switch (receivedResult, expectedResult) {
                
            case let  (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
                
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                
                XCTFail("Expexted result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (RemoteImageCommentsLoader, HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
 

}
