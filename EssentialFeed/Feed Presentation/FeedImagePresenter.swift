//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 24/09/2023.
//

public final class FeedImagePresenter {
   
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        
        return FeedImageViewModel (
            description: image.description,
            location: image.location)
    }
}

