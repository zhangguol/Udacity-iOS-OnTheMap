//
//  Result.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 6/29/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case failure(Error)
}

public extension Result {

    /// Evaluates the given closure when this `Result` instance is not `error`, passing
    /// the unwrapped value as a parameter.
    ///
    /// - Parameter f: A closure that takes the unwrapped value of the instance
    /// - Returns: The result of the given closure wrapped in the `Result`; If this instance
    ///            is `error`, returns `error`.
    public func map<U>(_ f: (T) throws -> U) rethrows -> Result<U> {
        switch self {
        case .success(let y): return .success(try f(y))
        case .failure(let error): return .failure(error)
        }
    }

    /// Evaluates the given closure when this `Result` instance is not `error`, passing
    /// the unwrapped value as a parameter.
    ///
    /// - Parameter f: A closure that takes the unwrapped value of the instance and returns
    ///                a wrapped value.
    /// - Returns: The result of the given closure wrapped in the `Result`; If this instance
    ///            is `error`, returns `error`.
    public func flatMap<U>(_ f: (T) throws -> Result<U>) rethrows -> Result<U> {
        switch self {
        case .success(let y): return try f(y)
        case .failure(let error): return .failure(error)
        }
    }
}
