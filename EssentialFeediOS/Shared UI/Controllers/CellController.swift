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
    let id: AnyHashable
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?
    
    public init(id: AnyHashable , _ dataSource: UITableViewDataSource &  UITableViewDelegate & UITableViewDataSourcePrefetching) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = dataSource
        self.dataSourcePrefetching = dataSource
    }
    
    public init(id: AnyHashable,_ dataSource: UITableViewDataSource ) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = nil
        self.dataSourcePrefetching = nil
    }
    
    public init(id: AnyHashable , _ dataSource: UITableViewDataSource &  UITableViewDelegate ) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = dataSource
        self.dataSourcePrefetching = nil
    }
}

extension CellControler:Equatable {
    public static func == (lhs: CellControler, rhs: CellControler) -> Bool {
        lhs.id == rhs.id
    }
}
extension CellControler: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
