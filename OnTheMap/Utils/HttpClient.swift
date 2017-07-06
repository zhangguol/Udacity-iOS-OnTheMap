//
//  HttpClient.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 6/29/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import Foundation

class HTTPClient {

    let session = URLSession(configuration: .default)

    deinit {
        session.invalidateAndCancel()
    }

    func jsonRequest<APIType>(
        api: APIType,
        completion: @escaping (Result<Any>) -> Void)
    where APIType: APIProtocol {
        do {
            let request = try generateRequest(for: api)
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard var data = data else {
                    completion(.failure(ErrorType.unknown))
                    return
                }

                api.responseDataDecorator(data: &data)

                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    completion(.success(json))
                } catch let jsonError {
                    completion(.failure(jsonError))
                }
            }

            task.resume()
        } catch let error {
            completion(.failure(error))
        }
    }
}

private extension HTTPClient {
    func generateRequest(for api: APIProtocol) throws -> URLRequest {
        guard
            var urlComponents = URLComponents(string: type(of: api).baseURL + "/" + api.path)
        else {
            throw ErrorType.invalidURL
        }
        
        if api.method == .get {
            urlComponents.queryItems = generateQueryItems(from: api.parameters)
        }

        guard let url = urlComponents.url else {
            throw ErrorType.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = api.method.rawValue
        api.requestDecorator(request: &request)

        if [.post, .delete].contains(api.method) {
            request.httpBody = getPostHTTPBody(from: api.parameters)
        }

        return request
    }
    
    func generateQueryItems(from parameters: [String: Any]) -> [URLQueryItem] {
        return parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
    }

    func getPostHTTPBody(from parameter: [String: Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: parameter, options: [])
    }
}

extension HTTPClient {
    enum ErrorType: Error {
        case invalidURL
        case unknown
    }
}
