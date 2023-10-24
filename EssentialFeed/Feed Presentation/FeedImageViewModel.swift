//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 24/09/2023.
//
 

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?
   
    
    public var hasLocation: Bool {
        return location != nil
    }
}
