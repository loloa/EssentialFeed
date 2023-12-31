//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 12/09/2023.
//

import UIKit
 

final class FeedRefreshViewController: NSObject {
    
    //private let disposeBag = DisposeBag()
    
    private let viewModel: FeedViewModel
 
    private(set) lazy var view: UIRefreshControl = binded(UIRefreshControl())
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
         viewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        
        viewModel.onLoadingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            }else {
                view?.endRefreshing()
            }
        }
 
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
    /*
     private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
         view.rx.controlEvent(.valueChanged)
                 .bind(to: viewModel.loadFeed)
                 .disposed(by: disposeBag)

         viewModel.isLoading
             .bind(to: view.rx.isRefreshing)
             .dispose(by: disposeBag)

         return view
     }
     */
}
