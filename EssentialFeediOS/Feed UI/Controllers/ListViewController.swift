//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 07/09/2023.
//


import UIKit
import EssentialFeed

public protocol FeedViewControllerDelegate {
    
    func didRequestFeedrefresh()
}

public protocol CellControler {
    
    func view(in: UITableView) -> UITableViewCell
    func preload()
    func cancelLoad()
}
 
extension CellControler {
    func startTask(cell: UITableViewCell){}
}
 
 public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
 
     private var loadingControllers = [IndexPath: CellControler]()
     
     @IBOutlet private(set) public weak var errorView: ErrorView?
     public var delegate: FeedViewControllerDelegate?
     
     
     convenience init(coder: NSCoder, delegate: FeedViewControllerDelegate) {
         self.init(coder: coder)!
         self.delegate = delegate
     }
 
     
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
          delegate?.didRequestFeedrefresh()
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
        return cellController(forRowAt: indexPath).view(in: tableView)
     }
    
     public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         let cellController = cellController(forRowAt: indexPath)
         cellController.startTask(cell: cell)
      }
 
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellcontrollerLoad(forRowAt: indexPath)
    }
 
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach (cancelCellcontrollerLoad)
        
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> CellControler {
        
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
         return controller
     }
     
     private func cancelCellcontrollerLoad(forRowAt indexPath: IndexPath) {
         loadingControllers[indexPath]?.cancelLoad()
         loadingControllers[indexPath] = nil
         //cellController(forRowAt: indexPath).cancelLoad()
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
    // private func startTask(forRowAt indexPath: IndexPath) {}
}
