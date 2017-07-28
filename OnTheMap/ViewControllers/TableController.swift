//
//  TableController.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/27/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import UIKit

class TableController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    var store: Store<Action, State, Command>!

    lazy var reducer: (State, Action) -> (state: State, command: Command?) = {
        [weak self] (state: State, action: Action) in

        var state = state
        var command: Command? = nil

        switch action {
        case .updateDataSource(let dataSource):
            state.dataSource = dataSource
        case .updateLoadingState(let isLoading):
            state.isLoading = isLoading
        }
        
        return (state, command)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        store = Store(reducer: reducer, initialState: State())
        store.subscribe { [weak self] state, prevState, command in
            self?.stateDidChanged(state: state, previousState: prevState, command: command)
        }
    }

    private func stateDidChanged(state: State, previousState: State?, command: Command?) {
        if previousState == nil
            || previousState!.dataSource.studentLocations != state.dataSource.studentLocations {

            tableView.dataSource = state.dataSource
            tableView.reloadData()
        }

        if previousState == nil
            || previousState!.isLoading != state.isLoading {

            (state.isLoading ? loadingIndicator.startAnimating : loadingIndicator.stopAnimating)()
        }
    }
    
}

extension TableController {
    struct State: StateType {
        var dataSource = OnTheMapDataSource(studentLocations: [])
        var isLoading = false
    }

    enum Action: ActionType {
        case updateDataSource(OnTheMapDataSource)
        case updateLoadingState(isLoading: Bool)
    }

    enum Command: CommandType {}
}
