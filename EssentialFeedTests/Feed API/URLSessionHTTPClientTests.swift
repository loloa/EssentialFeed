//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 08/08/2023.
//

import XCTest
import EssentialFeed

/*
 1. test we created Data task with right url
 */
 

final class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        
        let url = anyURL()
        let exp = expectation(description: "Wait for completion")
        URLProtocolStub.observeRequests { request in
            
            XCTAssertEqual(request.url,url )
            XCTAssertEqual(request.httpMethod,"GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        
        let requestError = NSError(domain: "any error", code: 1)
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        
        XCTAssertEqual((receivedError as NSError?)?.code, requestError.code)
        XCTAssertEqual((receivedError as NSError?)?.domain, requestError.domain)
        
    }
    
    
    func test_getFromURL_failsOnAllInvalidRepresantationCases() {
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_suceedsOnHTTPURLResponseWithData() {
        
        let data = anyData()
        
        let response = anyHTTPURLResponse()
        let receivedValues = resultValuesFor(data: data, response: response, error: nil)
        
        
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
        
    }
    
    func test_getFromURL_suceedsWithEmptyOnHTTPURLResponseWithNilData() {
        
        let response = anyHTTPURLResponse()
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
        
    }
    //MARK: - Helpers
    
    //this factory methods garantees that if we ever have to change this api ,
    //for example to add some dependences, we don't break tests that don't care about
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?,
                           file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Waiting for completion")
        var receivedResult: HTTPClientResult!
        
        sut.get(from: anyURL()) { result in
            
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
        
        
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?,
                                file: StaticString = #filePath, line: UInt = #line) -> Error? {
        
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
            
        case let .failure(error):
            //nothing to do appart of retrying
            return error
            
        default:
            XCTFail("Expected failure got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?,
                                 file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
            
        case let .success(data, response):
            return (data, response)
            
        default:
            XCTFail("Expected failure got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
 
    private class URLProtocolStub: URLProtocol {
        
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            
            let error: Error?
            let data: Data?
            let response: URLResponse?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?){
            
            stub = Stub(error: error, data: data, response: response)
        }
        static func observeRequests(observer: @escaping (URLRequest) -> Void){
            requestObserver = observer
            
        }
        static func startInterceptingRequest(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        //MARK: - Need to implemet
        
        // class method , is called before instance exists -> static
        // invoced before request even starts
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = URLProtocolStub.stub?.error {
                
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
        
    }
}
