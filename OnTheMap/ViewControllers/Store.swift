//
//  Store.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/17/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import Foundation

class Store<A: ActionType, S: StateType, C: CommandType> {
    let reducer: (_ state: S, _ action: A) -> (S, C?)
    private var subscriber: ((_ state: S, _ previousState: S, _ command: C?) -> Void)?

    private var subscriptions: [StoreSubscription<S, C>] = []

    var state: S

    init(reducer: @escaping (S, A) -> (S, C?), initialState: S) {
        self.reducer = reducer
        self.state = initialState
    }

    func dispatch(_ action: A) {
        let previousState = state
        let (nextState, command) = reducer(state, action)
        state = nextState

        subscriptions.map { $0.stateHandler }.forEach { $0(state, previousState, command) }
    }

    func subscribe(_ subscriber: StoreSubscriber, _ handler: @escaping (S, S, C?) -> Void) {
        subscriptions.append(
            StoreSubscription(
                subscriber: subscriber,
                stateHandler: handler
            )
        )
    }

    func unsubscribe(_ subscriber: StoreSubscriber ) {
        _ = subscriptions.index { $0.subscriber === subscriber }.map { subscriptions.remove(at: $0) }
    }
}
