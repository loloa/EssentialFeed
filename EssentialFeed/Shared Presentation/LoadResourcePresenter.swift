//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 22/10/2023.
//

import Foundation

public protocol ResourceView {
    
    associatedtype ResourceViewModel
    
    func display(_ viewModel: ResourceViewModel)
    
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    
    public typealias Mapper = (Resource) -> View.ResourceViewModel
    
    private let resourceView: View
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    private let mapper: Mapper
 
    
    public static var loadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR", tableName: "Shared", bundle: Bundle(for: Self.self), comment: "Error message displayed when we can't load the resource")
    }
    
    public init(resourceView: View, loadingView: FeedLoadingView, errorView: FeedErrorView, mapper: @escaping Mapper) {
 
        self.resourceView = resourceView
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }
    //data in -> transform -> data out to the UI
    
    // Void -> transform -> sends to the UI
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    // [FeedImage] -> transform -> sends to the UI
    // [ImageComment] -> transform -> sends to the UI
    // Data -> transform -> sends to the UI
    
    //Resource -> create ResourceviewModel -> sends to UI
    public func didFinishLoading(with resource: Resource) {
        resourceView.display(mapper(resource))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    // Eror -> transform -> sends to the UI
    public func didFinishLoading(with error: Error) {
        errorView.display(.error(message: Self.loadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
