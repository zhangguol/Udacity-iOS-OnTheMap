//
//  ErrorType.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/26/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import Foundation

enum ErrorType: LocalizedError {
    case serverSideError(msg: String)
    case notLogin
    case loginError
    case invalideWebsiteURL
    case locationNotFound
    case invalidURL
    case unknown

    var errorDescription: String? {
        switch self {
        case .serverSideError(let msg): return msg
        case .notLogin: return "Not login"
        case .loginError: return "Cannot login"
        case .invalideWebsiteURL:
            return "Invalid Link. Include HTTP(S)://"
        case .locationNotFound:
            return "Location Not Found"
        case .invalidURL:
            return "Invalid URL"
        case .unknown: return "Unknown Error"
        }
    }
}
