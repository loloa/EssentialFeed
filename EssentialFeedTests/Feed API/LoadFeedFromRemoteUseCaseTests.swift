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

final class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    
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
        
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
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
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        
        return .failure(error)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
 
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            
            switch (receivedResult, expectedResult) {
                
            case let  (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                
                XCTFail("Expexted result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (RemoteFeedLoader, HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
 }

