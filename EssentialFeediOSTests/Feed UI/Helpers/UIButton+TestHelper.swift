//
//  UIButton+TestHelper.swift
//  EssentialFeediOSTests
//
//  Created by אליסה לשין on 12/09/2023.
//

import UIKit

extension UIButton {
    
    func simulateTap() {
        simulate(event: .touchUpInside)
     }
}
