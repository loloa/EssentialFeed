//
//  FeedImageCell+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by אליסה לשין on 12/09/2023.
//

import UIKit
import EssentialFeediOS

//DSL
extension FeedImageCell {
    
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var isShowingRetryAction: Bool {
        return !feedImageRetryButton.isHidden
    }
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    var locationText: String? {
        return locationLabel.text
    }
    var descriptionText: String? {
        return descriptionLabel.text
    }
    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
    
    func simulateRetryAction(){
        feedImageRetryButton.simulateTap()
    }
}
