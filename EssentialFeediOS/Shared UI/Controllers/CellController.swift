//
//  CellController.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 26/10/2023.
//

import Foundation
import UIKit

//tuple composition
//public typealias CellControler = (dataSource: UITableViewDataSource, delegate: UITableViewDelegate?,dataSourcePrefetching: UITableViewDataSourcePrefetching?)

public struct CellControler {
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?
    
    public init(_ dataSource: UITableViewDataSource &  UITableViewDelegate & UITableViewDataSourcePrefetching) {
        self.dataSource = dataSource
        self.delegate = dataSource
        self.dataSourcePrefetching = dataSource
    }
    
    public init(_ dataSource: UITableViewDataSource ) {
        self.dataSource = dataSource
        self.delegate = nil
        self.dataSourcePrefetching = nil
    }
}

 
