//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by אליסה לשין on 21/08/2023.
//

import Foundation

func anyNSError()  -> NSError {
   return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}
 

 func anyData() -> Data {
    return Data("any data".utf8)
}

 extension HTTPURLResponse {
    
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}


 func makeItemsJSON(items: [[String: Any]]) -> Data {
    
    let itemsJSON = ["items" : items]

    let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
    return json
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
    
     func adding(minutes: Int) -> Date {
         return Calendar(identifier: .gregorian).date(byAdding: .minute, value: minutes, to: self)!
    }
    
     func adding(days: Int) -> Date {
         return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}
