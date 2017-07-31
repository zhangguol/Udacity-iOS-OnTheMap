//
//  ParseAPI.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 6/29/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import Foundation

enum ParseAPI: APIProtocol {

    case getStudentLocations(limit: Int?, skip: Int?, order: String?)
    case getStudentLocation(uniqueKey: String)
    case createStudentLocation(location: StudentLocation)
    case updateStudentLocation(id: String, location: StudentLocation)

    static let baseURL: String = "https://parse.udacity.com/parse/classes"

    var path: String {
        switch self {
            case .getStudentLocations,
                 .getStudentLocation,
                 .createStudentLocation:
                return "StudentLocation"
        case let .updateStudentLocation(id, _):
            return "StudentLocation/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getStudentLocations,
             .getStudentLocation:
            return .get
        case .createStudentLocation: return .post
        case .updateStudentLocation: return .put
        }
    }

    var parameters: [String : Any] {
        switch self {
        case .getStudentLocations(let params):
            var dict = [String: Any]()
            dict["limit"] = params.limit
            dict["skip"] = params.skip
            dict["order"] = params.order

            return dict
        case .getStudentLocation(let uniqueKey):
            return ["where": "{\"uniqueKey\":\"\(uniqueKey)\"}"]
        case.createStudentLocation(let location):
            return location.toJSON()
        case let .updateStudentLocation(_, location):
            return location.toJSON(withID: false)
        }
    }

    func requestDecorator(request: inout URLRequest) {
        var headers = [
            "X-Parse-Application-Id": Constant.appID,
            "X-Parse-REST-API-Key": Constant.apiKey
        ]

        switch self.method {
        case .post, .put:
            headers["Content-Type"] = "application/json"
        default: break
        }

        headers.forEach {
            request.addValue($1, forHTTPHeaderField: $0)
        }
    }
}

private extension ParseAPI {
    enum Constant {
        static let appID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
}

