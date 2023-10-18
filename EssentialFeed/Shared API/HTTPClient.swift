//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 07/08/2023.
//

import Foundation


/*
 Caio does not like this (Error?, HTTPURLResponse?) -> Void
 becase error has 2 states nil/int
 and response 2 states nil/ not nil
 so 4 cases when only 2 are possible
 
 (nil, respose)
 (error, nil)
 so he creates HTTPclintResult
 */

public protocol HTTPClientTask {
    func cancel()
}

// type, can be public, so other modules can use it

/// The completion handler can be invoked in any thread.
/// Clients are responsible to dispatch to appropriate threads, if needed.
public protocol HTTPClient {
    
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    @discardableResult
    func get(from url: URL, completion: @escaping(Result) -> Void) -> HTTPClientTask
    
}
