//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 25/10/2023.
//

import UIKit
import EssentialFeed

public class ImageCommentCellController: CellControler {
    
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImagecommentCell = tableView.dequeuReusableCell()
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        return cell
    }

}

