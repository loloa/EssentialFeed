//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 12/09/2023.
//

import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
    
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedImageCellController : FeedImageView {
    
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    
    public init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeuReusableCell()
        cell?.onReuse = { [weak self] in
                    self?.releaseCell()
                }
        delegate.didRequestImage()
        return cell!
    }
    
    public func display(_ viewModel: FeedImageViewModel<UIImage>) {
        
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        
        cell?.feedImageView.setImageAnimated(viewModel.image)
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImage
        cell?.onReuse = { [weak self] in
                    self?.releaseCell()
                }
        
    }
    
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func startTask(cell: UITableViewCell?) {
        self.cell = cell as? FeedImageCell
        delegate.didRequestImage()
    }
    func cancelLoad() {
        releaseCell()
        delegate.didCancelImageRequest()
    }
    
    private func releaseCell() {
        cell = nil
    }
}
 
