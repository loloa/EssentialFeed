//
//  HTTPClientProfilingDecorator.swift
//  EssentialApp
//
//  Created by אליסה לשין on 11/02/2024.
//

import os
import UIKit
import EssentialFeed

 class HTTPClientProfilingDecorator: HTTPClient {
    
    private let decoratee: HTTPClient
    private let logger: Logger
    
    init(decoratee: HTTPClient, logger: Logger) {
        self.decoratee = decoratee
        self.logger = logger
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> EssentialFeed.HTTPClientTask {
         
        logger.trace("Started loading url: \(url)")
        let startTime = CACurrentMediaTime()
        return decoratee.get(from: url) { [logger] result in
            
            if case let .failure(error) = result {
                logger.trace("Failed loading url: \(url), error \(error.localizedDescription)")
            }
            let elapsed = CACurrentMediaTime() - startTime
            logger.trace("Finished loading url: \(url), elapsed \(elapsed)")
            completion(result)
        }
    }
}
