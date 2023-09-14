//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 13/09/2023.
//


import EssentialFeed

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: (Data) -> Image?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    var hasLocation: Bool {
        return model.location != nil
    }
    
    var location: String? {
        return model.location
    }
    var description: String? {
        return model.description
    }
    
    var onImageLoadingStateChange: Observer<Bool>?
    var onImageLoad: Observer<Image>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageData() {
        
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.handle(result: result)
        }
    }
    
    private func handle(result: FeedImageDataLoader.Result) {
        
        if let image = (try? result.get()).flatMap(imageTransformer){
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        
        onImageLoadingStateChange?(false)
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
