//
//  APIProtocol.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 6/29/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}

protocol APIProtocol {
    static var baseURL: String { get }

    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any] { get }

    func requestDecorator(request: inout URLRequest)
    func responseDataDecorator(data: inout Data)
}

extension APIProtocol {
    func requestDecorator(request: inout URLRequest) {
        // do nothing by default
    }
    
    func responseDataDecorator(data: inout Data) {
        // do nothing by default
    }
}
