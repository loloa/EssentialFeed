//
//  UITableView+Dequeing.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 17/09/2023.
//

import UIKit


extension UITableView {
    func dequeuReusableCell<T: UITableViewCell>() -> T {
        
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
