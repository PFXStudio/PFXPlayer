//
//  ErrorEnums.swift
//  PFXPlayer
//
//  Created by succorer on 2020/01/22.
//  Copyright © 2020 pfxstudio. All rights reserved.
//

import Foundation

public enum BVError: Int {
    case network_invalid_url = 40000
    case network_invalid_response_data
    case network_invalid_parameter
}

struct AdaptError: Error {
    let error: NSError
}

extension Error {
    var nsError: NSError? { return (self as? AdaptError)?.error }
}
