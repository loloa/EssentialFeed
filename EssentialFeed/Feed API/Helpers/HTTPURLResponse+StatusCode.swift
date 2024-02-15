//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by אליסה לשין on 28/09/2023.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
