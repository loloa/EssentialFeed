//
//  ResourceErrorViewModel.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 24/09/2023.
//

public struct ResourceErrorViewModel {
    
    public let message: String?
    static var noError: ResourceErrorViewModel {
        return ResourceErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ResourceErrorViewModel {
        return ResourceErrorViewModel(message: message)
    }
}
