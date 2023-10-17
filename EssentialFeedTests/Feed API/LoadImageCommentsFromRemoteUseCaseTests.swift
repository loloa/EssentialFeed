//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 17/10/2023.
//

import XCTest
import EssentialFeed

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
        
    func test_load_requestsDataFromURL() {
        
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in}
        XCTAssertEqual(client.requestedURLs, [url])
        
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in}
        sut.load { _ in}
        
        XCTAssertEqual(client.requestedURLs, [url, url])
        
    }
    
    
    func test_load_deliversErrorOnClientError() {
        
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity)) {
            
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
        
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let json = makeItemsJSON(items: [])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData)) {
            
            let invalidJson =  Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        }
    }
    
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems(){
        
        let (sut, client) = makeSUT()
        
        let (item1, item1JSON) = makeItem(id: UUID(),
                             description: nil,
                             location: nil,
                             imageURL: URL(string: "https://a-url.com")!)
 
        let (item2, item2JSON) = makeItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "https://another-url.com")!)
 
        expect(sut, toCompleteWith: .success([item1, item2]), when: {
            
            let json = makeItemsJSON(items: [item1JSON, item2JSON])
            client.complete(withStatusCode: 200, data: json)
        })
         
    }
    
    
    
    func test_load_deliversErrorOn200HTTPResponseWithEmtyJsonList() {
        
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            
            let emptyListJSON = makeItemsJSON(items: [])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    //it also can be reversed, we want the completion to be called after deallocation
    func test_load_doesnotDeliverResultAfterSUTInstancehasBeenDeallocated(){
        
        let url = URL(string: "https://any_url.com")!
        let client = HTTPClientSpy()
        
        var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(url: url, client: client)
        
        var capturedResults = [RemoteImageCommentsLoader.Result]()
        sut?.load {   capturedResults.append($0)}
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON(items: []))
        XCTAssertTrue(capturedResults.isEmpty)
        
        
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
