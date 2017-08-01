//
//  AddLocationController.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/28/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import UIKit
import MapKit

class AddLocationController: UIViewController, StoreSubscriber {

    static func initFromStoryboard(studentLoaction: StudentLocation) -> AddLocationController {
        let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "AddLocationController")
            as! AddLocationController

        vc.store = Store(reducer: vc.reducer, initialState: State(studentLocation: studentLoaction))
        
        return vc
    }

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    var store: Store<Action, State, Command>!

    private(set) lazy var reducer: (State, Action) -> (State, Command?) = {
        [weak self] (state: State, action: Action) in

        var state = state
        var command: Command? = nil

        switch action {
        case .updateLocation(let newLocation): state.studentLocation.mapString = newLocation
        case .updateWebsite(let newWebsite): state.studentLocation.mediaURL = newWebsite
        case .updateLoadingState(let isLoading): state.isLoading = isLoading
        case let .updateCoordinate(latitude, longitude):
            state.studentLocation.latitude = latitude
            state.studentLocation.longitude = longitude
        case .cancel: command = .cancel
        case let .findLocation(location):
            command = .findLocation(location: location) { result in
                self?.store.dispatch(.updateLoadingState(isLoading: false))
                switch result {
                case .success(let (location, placemark)):
                    self?.store.dispatch(.showMap(ofLocation: location, placemark: placemark))
                case .failure(let error):
                    self?.showErrorAlert(with: error.localizedDescription, title: "Location Not Found")
                }
            }
        case .showErrorAlert(let msg): command = .showErrorAlert(message: msg)
        case .showMap(let (location, placemark)): command = .showMap(ofLocation: location, placemark: placemark)
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

    private func stateChanged(state: State, previousState: State?, command: Command?) {
        if let command = command {
            switch command {
            case .cancel:
                navigationController?.popViewController(animated: true)
            case let .findLocation(location, handler):
                store.dispatch(.updateLoadingState(isLoading: true))
                findLoaction(location, completion: handler)
            case .showErrorAlert(message: let msg):
                showErrorAlert(with: msg)
            case let .showMap(location, placemark):
                let vc = PreviewLoactionController.initFromStoryboard(location: location, placemarkToPreview: placemark)
                navigationController?.pushViewController(vc, animated: true)
            }
        }

        if previousState == nil
            || previousState!.studentLocation.mapString != state.studentLocation.mapString {
            locationTextField.text = state.studentLocation.mapString
        }

        if previousState == nil
            || previousState!.studentLocation.mediaURL != state.studentLocation.mediaURL {
            websiteTextField.text = state.studentLocation.mediaURL
        }

        if previousState == nil
            || previousState!.isLoading != state.isLoading {
            (state.isLoading ? loadingIndicator.startAnimating : loadingIndicator.stopAnimating)()
            findLocationButton.isEnabled = !state.isLoading
        }
    }
}

extension AddLocationController {

    @IBAction func locationEditingChanged(_ sender: UITextField) {
        store.dispatch(.updateLocation(sender.text ?? ""))
    }

    @IBAction func websiteEditingChagned(_ sender: UITextField) {
        store.dispatch(.updateWebsite(sender.text ?? ""))
    }

    @IBAction func findLocationButtonTapped(_ sender: UIButton) {
        store.dispatch(.findLocation(store.state.studentLocation))
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        store.dispatch(.cancel)
    }
}

private extension AddLocationController {

    func findLoaction(_ location: StudentLocation, completion: @escaping (Result<(StudentLocation, MKPlacemark)>) -> Void) {
        guard validate(website: location.mediaURL) else {
            completion(.failure(ErrorType.invalideWebsiteURL))
            return
        }

        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = location.mapString

        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    
                    return
                }

                guard let searchResponse = response,
                    let mapItem = searchResponse.mapItems.first else {
                    completion(.failure(ErrorType.locationNotFound))
                    return
                }

                var location = location
                let coordinate = mapItem.placemark.coordinate
                location.latitude = coordinate.latitude
                location.longitude = coordinate.longitude

                completion(.success((location, mapItem.placemark)))
            }
        }
    }

    func validate(website: String) -> Bool {
        let validPrefixes = ["http://", "https://"]
        let lowercased = website.lowercased()
        return validPrefixes.reduce(false) { $0 || lowercased.hasPrefix($1) }
    }
}

extension AddLocationController {
    struct State: StateType {
        var isLoading: Bool = false

        var studentLocation: StudentLocation

        init(
            isLoading: Bool = false,
            studentLocation: StudentLocation
        ) {
            self.isLoading = isLoading
            self.studentLocation = studentLocation
        }
    }

    enum Action: ActionType {
        case updateLocation(String)
        case updateWebsite(String)
        case updateCoordinate(latitude: Double, longtitude: Double)
        case cancel
        case findLocation(StudentLocation)
        case updateLoadingState(isLoading: Bool)
        case showErrorAlert(message: String)
        case showMap(ofLocation: StudentLocation, placemark: MKPlacemark)
    }

    enum Command: CommandType {
        case cancel
        case findLocation(
            location: StudentLocation,
            completion: (Result<(StudentLocation, MKPlacemark)>) -> Void
        )
        case showErrorAlert(message: String)
        case showMap(ofLocation: StudentLocation, placemark: MKPlacemark)
    }
}
