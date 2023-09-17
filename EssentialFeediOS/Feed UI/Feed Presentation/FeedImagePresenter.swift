//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 17/09/2023.
//


import EssentialFeed

protocol FeedImageView {
    
    associatedtype Image
    func display(_ model: FeedImageViewModel<Image>)
 }

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    
    private var view: View
    private let imageTransformer: (Data) -> Image?
 
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    private struct InvalidImageDataError: Error {}
   
    func didStartLoadingImageData(for model: FeedImage) {
        
        
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        
        let viewModel: FeedImageViewModel<Image> = FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: false,
            shouldRetry: true)
        view.display(viewModel)
    }
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        let viewModel = FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: image,
            isLoading: false,
            shouldRetry: false)
        view.display(viewModel)
    }
 
}

