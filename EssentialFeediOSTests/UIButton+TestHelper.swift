//
//  UIButton+TestHelper.swift
//  EssentialFeediOSTests
//
//  Created by אליסה לשין on 12/09/2023.
//

import UIKit

extension UIButton {
    
    func simulateTap() {
        
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0), with: nil)
            }
        }
    }
}
