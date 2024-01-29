//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 07/09/2023.
//


import UIKit
import EssentialFeed
 
 public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
     
     private(set) public var errorView: ErrorView = ErrorView()
     private var onViewIsAppearing: (() -> Void)?
 
     private lazy var dataSource: UITableViewDiffableDataSource<Int, CellControler> = {
         
         .init(tableView: tableView) { (tableView, indexPath, controller) -> UITableViewCell? in
             print("\(indexPath.row)")
             return controller.dataSource.tableView(tableView, cellForRowAt: indexPath)
         }
     }()
     
     public var onRefresh: (() -> Void)?
     
     public override func viewDidLoad() {
         super.viewDidLoad()
          
         configureTableView()
         
         onViewIsAppearing = { [weak self] in
             self?.refresh()
             self?.onViewIsAppearing = nil
         }
     }
     
     public override func viewIsAppearing(_ animated: Bool) {
         super.viewIsAppearing(animated)
         onViewIsAppearing?()
     }
     
     private func configureTableView() {
         dataSource.defaultRowAnimation = .fade
         tableView.dataSource = dataSource
         tableView.tableHeaderView = errorView.makeContainer()

         errorView.onHide = { [weak self] in
             self?.tableView.beginUpdates()
             self?.tableView.sizeTableHeaderToFit()
             self?.tableView.endUpdates()
         }
     }

     public override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
         
         tableView.sizeTableHeaderToFit()
     }
     
     public override func traitCollectionDidChange(_ previous: UITraitCollection?) {
         if previous?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
             tableView.reloadData()
         }
     }
     
     @IBAction private func refresh() {
          onRefresh?()
      }
     
     
     public func display(_ cellControllers: [CellControler]) {
          
         var snapshot = NSDiffableDataSourceSnapshot<Int, CellControler>()
         snapshot.appendSections([0])
         snapshot.appendItems(cellControllers)
         
         if #available(iOS 15.0, *) {
             dataSource.applySnapshotUsingReloadData(snapshot)
         } else {
             dataSource.apply(snapshot)
         }
     }
  
     public func display(_ viewModel: ResourceLoadingViewModel) {
         refreshControl?.update(isRefreshing: viewModel.isLoading)
     }
     
     public func display(_ viewModel: ResourceErrorViewModel) {
          errorView.message =  viewModel.message
       }
    
     public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let dl = cellController(at: indexPath)?.delegate
         dl?.tableView?(tableView, didSelectRowAt: indexPath)
         
     }
     
     public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//         let cellController = cellController(forRowAt: indexPath)
//         cellController.startTask(cell: cell)
         let dl = cellController(at: indexPath)?.delegate
         dl?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
      }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
     }
 
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { indexPath in
            
            let dsp = cellController(at: indexPath)?.dataSourcePrefetching
            dsp?.tableView(tableView, prefetchRowsAt: indexPaths)
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
        
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.dataSourcePrefetching
            dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
        
    }
    
    private func cellController(at indexPath: IndexPath) -> CellControler? {
        
        dataSource.itemIdentifier(for: indexPath)
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


extension UIView {
    public func makeContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(self)

        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: container.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            topAnchor.constraint(equalTo: container.topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        return container
    }
}

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
