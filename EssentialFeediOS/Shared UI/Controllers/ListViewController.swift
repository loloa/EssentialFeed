//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 07/09/2023.
//


import UIKit
import EssentialFeed



public typealias CellControler = UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching

 
 public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
 
     private var loadingControllers = [IndexPath: CellControler]()
     
     @IBOutlet private(set) public weak var errorView: ErrorView?
     public var onRefresh: (() -> Void)?
     
     
//     convenience init(coder: NSCoder, delegate: FeedViewControllerDelegate) {
//         self.init(coder: coder)!
//         self.delegate = delegate
//     }
 
     
    private var tableModel = [CellControler]() {
        didSet { tableView.reloadData() }
    }
     
     public func display(_ cellControllers: [CellControler]) {
         loadingControllers = [:]
         tableModel = cellControllers
     }
 
    public override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
     
     public override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
         
         tableView.sizeTableHeaderToFit()
     }
     
     @IBAction private func refresh() {
          onRefresh?()
      }
     
     public func display(_ viewModel: ResourceLoadingViewModel) {
         if viewModel.isLoading {
             refreshControl?.beginRefreshing()
         }else {
             refreshControl?.endRefreshing()
         }
     }
     
     public func display(_ viewModel: ResourceErrorViewModel) {
         if let message = viewModel.message {
             errorView?.show(message: message)
         }else {
             errorView?.hideMessage()
         }
      }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellController = cellController(forRowAt: indexPath)
        return cellController.tableView(tableView, cellForRowAt: indexPath)
      }
    
     public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//         let cellController = cellController(forRowAt: indexPath)
//         cellController.startTask(cell: cell)
       //  let dl = cellController(at: indexPath)?.delegate
       //  dl?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
      }
 
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let controller = removeLoadingController(forRowAt: indexPath)
        controller.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
     }
 
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { indexPath in
            
            let cellController = cellController(forRowAt: indexPath)
            cellController.tableView(tableView, prefetchRowsAt: indexPaths)
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
        
        indexPaths.forEach { indexPath in
            let cellController = cellController(forRowAt: indexPath)
            cellController.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
        
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> CellControler {
        
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
         return controller
     }
     
     private func removeLoadingController(forRowAt indexPath: IndexPath) -> CellControler {
         let cellController = cellController(forRowAt: indexPath)
         loadingControllers[indexPath] = nil
        return cellController
     }
    /*
     On iOS 15+, the cell lifecycle behavior changed. For performance reasons, when the cell is removed from the table view and quickly added back (e.g., by scrolling up and down fast), the data source may not recreate the cell anymore using the cellForRow method if there's a cached cell for that IndexPath.
     
     If there’s a cached cell for that IndexPath, it'll just call willDisplayCell to avoid recreating a cell that’s already cached. This is more performant. However, we cancel requests on didEndDisplayingCell and only load them again if cellForRow is called. In this scenario, there's a possibility of the cached cell becoming visible again and never displaying an image until cellForRow is called after scrolling the table up and down again.
     
     So on iOS 15+, if we cancel any resource loading on didEndDisplayingCell, we must load/reload those resources on willDisplayCell.
     
     public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
     cancelTask(forRowAt: indexPath)
     }
     public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
     startTask(forRowAt: indexPath)
     }
     */
    
 
}
