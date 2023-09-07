//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 07/09/2023.
//


import UIKit
import EssentialFeed

final public class FeedViewController: UITableViewController {
    
    private var loader: FeedLoader?
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    
    @objc private func load() {
        
        refreshControl?.beginRefreshing()
        loader?.load(completion: {[weak self] _ in
            self?.refreshControl?.endRefreshing()
        })
    }
}
