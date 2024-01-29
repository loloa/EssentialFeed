//
//  LoadMoreCell.swift
//  EssentialFeediOS
//
//  Created by אליסה לשין on 29/01/2024.
//

import UIKit

public class LoadMoreCell: UITableViewCell {
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        contentView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        return spinner
    }()
    
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .footnote)
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            contentView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            contentView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        return label
    }()
    
    
    public var isLoading: Bool {
        
        get { return spinner.isAnimating}
        set {
            if newValue {
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
        }
    }
    
    public var message: String? {
        
        get { return messageLabel.text }
        set {
            messageLabel.text = newValue
        }
    }
}
