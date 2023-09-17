//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 12/09/2023.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellController : FeedImageView {
    
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in table: UITableView) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "FeedImageCell") as! FeedImageCell
        self.cell = cell
        delegate.didRequestImage()
        return cell
    }
    
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        
        cell?.feedImageView.image = viewModel.image
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImage
    }
    
    
    func preload() {
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

