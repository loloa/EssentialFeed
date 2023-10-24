//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 24/10/2023.
//

import Foundation
 
public final class ImageCommentsPresenter {
    
   
    public static var title: String {
        return NSLocalizedString(
            "IMAGE_COMMENTS_VIEW_TITLE",
            tableName: "ImageComments",
            bundle: Bundle(for: Self.self),
            comment: "Title for the comments screen")
    }
 
}
