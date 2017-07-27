//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/27/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingCoverView: UIView!
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
        store = Store(
            reducer: reducer,
            initialState: State(dataSource: OnTheMapDataSource(studentLocations: []), isLoading: false)
        )
        store!.subscribe { [weak self] state, prevState, command in
            self?.stateDidChanged(state: state, previousState: prevState, command: command)
        }

        stateDidChanged(state: store.state, previousState: nil, command: nil)
    }

    private func stateDidChanged(state: State, previousState: State?, command: Command?) {
        if previousState == nil
            || previousState!.dataSource.studentLocations != state.dataSource.studentLocations {

            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(state.dataSource.studentLocationAnnotations)
        }

        if previousState == nil
            || previousState!.isLoading != state.isLoading {

            loadingCoverView.isHidden = !state.isLoading
            (state.isLoading ? loadingIndicator.startAnimating : loadingIndicator.stopAnimating)()
        }
    }
}

extension MapViewController {

    struct State: StateType {
        var dataSource: OnTheMapDataSource
        
        var isLoading: Bool
    }

    enum Action: ActionType {
        case updateDataSource(OnTheMapDataSource)
        case updateLoadingState(isLoading: Bool)
    }

    enum Command: CommandType {}
}
