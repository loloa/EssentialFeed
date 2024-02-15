//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 10/09/2023.
//

import UIKit

public final class FeedImageCell: UITableViewCell {

    @IBOutlet private(set) public var locationContainer     : UIView!
    @IBOutlet private(set) public var locationLabel         : UILabel!
    @IBOutlet private(set) public var descriptionLabel      : UILabel!
    @IBOutlet private(set) public var feedImageContainer    : UIView!
    @IBOutlet private(set) public var feedImageView         : UIImageView!
    
    @IBOutlet private(set) public var feedImageRetryButton: UIButton!
 
    var onRetry: (() -> Void)?
    var onReuse: (() -> Void)?
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        onReuse?()
    }

    @IBAction func retryButtonTapped() {
         onRetry?()
    }
}
