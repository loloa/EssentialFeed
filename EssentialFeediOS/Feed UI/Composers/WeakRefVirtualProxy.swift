//
//  WeakRefVirtualProxy.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 18/09/2023.
//

import UIKit

 final class WeakRefVirtualProxy<T: AnyObject> {
    
    private weak var object: T?
     
    init(_ object: T) {
        self.object = object
    }
}
extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
 }

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel) {
        object?.display(viewModel)
    }
 }

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
     
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
    }
}
