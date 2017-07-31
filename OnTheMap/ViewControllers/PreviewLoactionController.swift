//
//  PreviewLoactionController.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/29/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import UIKit
import MapKit

class PreviewLoactionController: UIViewController, StoreSubscriber {

    static func initFromStoryboard(
        location: StudentLocation,
        placemarkToPreview: MKPlacemark
    ) -> PreviewLoactionController {
        let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "PreviewLoactionController")
            as! PreviewLoactionController
        vc.store = Store(
            reducer: vc.reducer,
            initialState: PreviewLoactionController.State(
                studentLocation: location,
                placemark: placemarkToPreview
            )
        )
        
        return vc
    }
    
    @IBOutlet weak var mapView: MKMapView!

    var store: Store<Action, State, Command>!
    lazy var reducer: (State, Action) -> (State, Command?) = {
        [weak self] (state: State, action: Action) in

        var state = state
        var command: Command? = nil

        switch action {
        case .saveLocation(let location):
            command = .saveLocation(location: location) { result in
                switch result {
                case .success: self?.store.dispatch(.backToMapView)
                case .failure(let error):
                    self?.store.dispatch(.showErrorAlert(message: error.localizedDescription))
                }
            }
        case .showErrorAlert(let msg): command = .showErrorAlert(message: msg)
        case .backToMapView: command = .backToMapView
        }

        return (state, command)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        store.subscribe(self) { [weak self] state, prevState, command in
            self?.stateChanged(state: state, previousState: prevState, command: command)
        }

        stateChanged(state: store.state, previousState: nil, command: nil)
    }

    @IBAction func finishButtonTapped(_ sender: UIButton) {
        store.dispatch(.saveLocation(store.state.studentLocation))
    }

    private func stateChanged(state: State, previousState: State?, command: Command?) {
        if let command = command {
            switch command {
            case let .saveLocation(location, handler):
                save(location: location, completion: handler)
            case .showErrorAlert(let msg):
                showErrorAlert(with: msg)
            case .backToMapView:
                navigationController?.popToRootViewController(animated: true)
            }
        }

        if previousState == nil
            || previousState!.studentLocation.longitude != state.studentLocation.longitude
            || previousState!.studentLocation.latitude != state.studentLocation.latitude {

            mapView.removeAnnotations(mapView.annotations)
            let annotation = state.placemark

            mapView.addAnnotation(annotation)
            mapView.showAnnotations([annotation], animated: true)
        }
    }
}

private extension PreviewLoactionController {
    func save(location: StudentLocation, completion: @escaping (Result<Void>) -> Void) {
        let api: ParseAPI = {
            if let id = location.objectID {
                return .updateStudentLocation(id: id, location: location)
            } else {
                return .createStudentLocation(location: location)
            }
        }()

        HTTPClient.shard.jsonRequest(api: api) { result in
            DispatchQueue.main.async {
                completion(result.map { _ in })
            }
        }
    }
}

extension PreviewLoactionController {
    struct State: StateType {
        var studentLocation: StudentLocation
        var placemark: MKPlacemark
    }

    enum Action: ActionType {
        case saveLocation(StudentLocation)
        case showErrorAlert(message: String)
        case backToMapView
    }

    enum Command: CommandType {
        case saveLocation(location: StudentLocation, completion: (Result<Void>) -> Void)
        case showErrorAlert(message: String)
        case backToMapView
    }
}
