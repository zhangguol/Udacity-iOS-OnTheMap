//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 8/1/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import Foundation

struct UdacityClient {
    static func login(username: String, password: String, completion: @escaping (Result<UdacityAccount>) -> Void) {
        HTTPClient.shard.jsonRequest(
            api: UdacityAPI.postSession(username: username, password: password)
        ) { result in
            DispatchQueue.main.async {
                completion(result.flatMap { json in
                    guard let json = json as? [String: Any] else {
                        return .failure(ErrorType.unknown)
                    }

                    if let accountJSON = json["account"] as? [String: Any],
                        let account = UdacityAccount(json: accountJSON) {
                        return .success(account)
                    } else if let error = json["error"] as? String {
                        return .failure(ErrorType.serverSideError(msg: error))
                    } else {
                        return .failure(ErrorType.unknown)
                    }
                })
            }
        }
    }
    
    static func fetchUserData(completion: @escaping (Result<UserData>) -> Void) {
        guard let userID = AppState.shared.loginedAccount?.key else {
            completion(.failure(ErrorType.loginError))
            return
        }
        HTTPClient.shard.jsonRequest(api: UdacityAPI.getPublicUserData(userID: userID)) { result in
            let processedResult: Result<UserData> = result.flatMap { json in
                guard
                    let json = json as? [String: Any],
                    let userJSON = json["user"] as? [String: Any],
                    let userData = UserData(json: userJSON)
                else {
                    return .failure(ErrorType.unknown)
                }

                return .success(userData)
            }

            DispatchQueue.main.async { completion(processedResult) }
        }
    }
}
