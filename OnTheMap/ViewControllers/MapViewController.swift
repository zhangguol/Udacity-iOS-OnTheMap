//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/27/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, StoreSubscriber {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingCoverView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    var parentController: TabBarController? {
        return tabBarController as? TabBarController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let parentVC = parentController {
            parentVC.store.subscribe(self) { [weak self] state, prevState, command in
                self?.stateDidChanged(state: state, previousState: prevState, command: command)
            }

            stateDidChanged(state: parentVC.store.state, previousState: nil, command: nil)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        parentController?.store.unsubscribe(self)
    }

    private func stateDidChanged(state: TabBarController.State, previousState: TabBarController.State?, command: TabBarController.Command?) {
        if previousState == nil
            || previousState!.dataSource != state.dataSource {

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
