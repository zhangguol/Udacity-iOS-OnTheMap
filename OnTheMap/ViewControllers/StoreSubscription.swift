//
//  StoreSubscription.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/28/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import Foundation

protocol StoreSubscriber: class {}

struct StoreSubscription<S: StateType, C: CommandType> {
    let subscriber: StoreSubscriber
    let stateHandler: (S, S, C?) -> Void
}
