//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 09/08/2023.
//

import Foundation


public class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresantation: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void){
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }else if let data = data, let response = response as? HTTPURLResponse{
                completion(.success((data, response)))
            }
            else {
                completion(.failure(UnexpectedValuesRepresantation()))
            }
        }.resume()
    }
}
