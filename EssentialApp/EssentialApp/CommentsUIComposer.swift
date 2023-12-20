//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by אליסה לשין on 18/12/2023.
//

//
//  CommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 12/09/2023.
//


import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

public final class CommentsUIComposer {
    
    private init(){}
    
    private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>
    
    public static func commentsComposedWith(commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>) -> ListViewController {
        
        let presentationAdapter = CommentsPresentationAdapter(
            loader: { commentsLoader().dispatchOnMainQueue() })

        
 
        let commentsController = makeCommentsViewController(
            title: ImageCommentsPresenter.title)
        
        commentsController.onRefresh =  presentationAdapter.loadResource
       
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: CommentsViewAdapter(
                controller: commentsController),
            loadingView: WeakRefVirtualProxy(commentsController),
            errorView: WeakRefVirtualProxy(commentsController),
            mapper: { ImageCommentsPresenter.map($0)} )
        
        return commentsController
    }
    
    private static func makeCommentsViewController(title: String) -> ListViewController {
        
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.title = title
        return controller
    }
}
 
 
final class CommentsViewAdapter: ResourceView {

   private weak var controller: ListViewController?
 
   init(controller: ListViewController ) {
       self.controller = controller
    }
    
   func display(_ viewModel: ImageCommentsViewModel) {
 
       controller?.display(viewModel.comments.map { viewModel in
           return CellControler(id: viewModel, ImageCommentCellController(model: viewModel))
       } )
      
   }
}
 

