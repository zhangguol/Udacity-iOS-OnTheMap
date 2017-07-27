//
//  ErrorType.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/26/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import Foundation

enum ErrorType: Error {
    case serverSideError(msg: String)
    case notLogin
    case unknown

    var localizedDescription: String {
        switch self {
        case .serverSideError(let msg): return msg
        case .notLogin: return "Not login"
        case .unknown: return "Unknown Error"
        }
    }
}
