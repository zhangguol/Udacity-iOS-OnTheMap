//
//  UdacityAPI.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/5/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import Foundation

enum UdacityAPI: APIProtocol {

    case postSession(username: String, password: String)
    case deleteSession
    case getPublicUserData(userID: String)

    static let baseURL: String = "https://www.udacity.com/api"

    var path: String {
        switch self {
        case .postSession, .deleteSession: return "session"
        case .getPublicUserData(let userID): return "users/\(userID)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .postSession: return .post
        case .deleteSession: return .delete
        case .getPublicUserData: return .get
        }
    }

    var parameters: [String : Any] {
        switch self {
        case let .postSession(username, password):
            return [
                "udacity": [
                    "username": username,
                    "password": password
                ]
            ]
        case .deleteSession, .getPublicUserData:
            return [:]
        }
    }

    func requestDecorator(request: inout URLRequest) {
        switch self {
        case .deleteSession:
            HTTPCookieStorage.shared.cookies?
                .filter { $0.name == "XSRF-TOKEN" }
                .first
                .map { request.setValue($0.value, forHTTPHeaderField: "X-XSRF-TOKEN") }
            
        default: break
        }
    }

    func responseDataDecorator(data: inout Data) {
        let range = Range(5..<data.count)
        data = data.subdata(in: range)
    }
}
