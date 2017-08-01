//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 8/1/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import Foundation

struct ParseClient {
    static func fetchStudentLocations(completion: @escaping (Result<[StudentLocation]>) -> Void) {
        let api = ParseAPI.getStudentLocations(limit: 100, skip: nil, order: "-updatedAt")
        HTTPClient.shard.jsonRequest(api: api) { result in
            let processedResult: Result<[StudentLocation]> = result.flatMap { json in
                guard
                    let json = json as? [String: Any],
                    let results = json["results"] as? [[String: Any]]
                    else {
                        return .failure(ErrorType.unknown)
                }
                
                let locations = results.flatMap(StudentLocation.init(json:))
                return .success(locations)
            }
            
            DispatchQueue.main.async { completion(processedResult) }
        }
    }
    static func getLocation(forUser uniqueKey: String,
                     completion: @escaping(Result<StudentLocation?>) -> Void) {
        
        HTTPClient.shard.jsonRequest(api: ParseAPI.getStudentLocation(uniqueKey: uniqueKey)) { result in
            let processedResult: Result<StudentLocation?> = result.flatMap { json in
                guard
                    let json = json as? [String: Any],
                    let results = json["results"] as? [[String: Any]]
                else {
                    return .failure(ErrorType.unknown)
                }

                return .success(results.first.flatMap(StudentLocation.init(json:)))
            }

            DispatchQueue.main.async { completion(processedResult) }
        }
    }
    
    static func create(location: StudentLocation, completion: @escaping (Result<Void>) -> Void) {
        HTTPClient.shard.jsonRequest(api: ParseAPI.createStudentLocation(location: location)) { result in
            DispatchQueue.main.async { completion(result.map { _ in }) }
        }
    }
    
    static func update(location: StudentLocation, completion: @escaping (Result<Void>) -> Void) {
        guard let id = location.objectID else {
            fatalError()
        }
        
        HTTPClient.shard.jsonRequest(api: ParseAPI.updateStudentLocation(id: id, location: location)) { result in
            DispatchQueue.main.async { completion(result.map { _ in }) }
        }
    }
}
