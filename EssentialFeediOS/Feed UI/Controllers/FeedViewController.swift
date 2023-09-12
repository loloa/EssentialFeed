//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 07/09/2023.
//


import UIKit
import EssentialFeed



final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
 
    
    private var feedLoader: FeedLoader?
    private var imageLoader: FeedImageDataLoader?
    private var tableModel = [FeedImage]()
    private var tasks = [IndexPath: FeedImageDataLoaderTask]()
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        tableView.prefetchDataSource = self
        load()
    }
    
    
    @objc private func load() {
        
        refreshControl?.beginRefreshing()
        feedLoader?.load(completion: {[weak self] result in
            
            if let feed = (try? result.get()) {
                self?.tableModel = feed
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        })
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (cellModel.location == nil)
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.text = cellModel.description
        cell.feedImageView.image = nil
        cell.feedImageContainer.startShimmering()
        cell.feedImageRetryButton.isHidden = true
 
        let loadImage = { [weak self, weak cell] in
            
            guard let self = self else {
                return
            }
            
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: cellModel.url) { [weak cell] result in
                let data = try? result.get()
                let image = data.map( UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageContainer.stopShimmering()
                cell?.feedImageRetryButton.isHidden = (image != nil)
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
 
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }
    
//    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        startTask(forRowAt: indexPath)
//    }
//
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
         
        indexPaths.forEach { indexPath in
            let cellModel = tableModel[indexPath.row]
            tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.url) { _ in }
        }
     }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach (cancelTask)
        
    }
    private func cancelTask(forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
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
