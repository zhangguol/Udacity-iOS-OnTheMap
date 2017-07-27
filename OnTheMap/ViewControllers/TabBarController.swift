//
//  TabBarController.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/26/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    var mapController: MapViewController? {
        return viewControllers?[0] as? MapViewController
    }

    var store: Store<Action, State, Command>!

    lazy var reducer: (State, Action) -> (state: State, command: Command?) = {
        [weak self] (state: State, action: Action) in

        var state = state
        var command: Command? = nil

        switch action {
        case .updateLocations(let locations):
            state = State(dataSource: OnTheMapDataSource(studentLocations: locations))
        case .loadLocations:
            command = .loadLocations { result in
                switch result {
                case .success(let locations):
                    self?.store.dispatch(.updateLocations(locations))
                case .failure(let error):
                    self?.store.dispatch(.showErrorAlert(message: error.localizedDescription))
                }
            }
        case .logout: command = .logout
        case .checkPosted:
            command = .checkPosted { result in
                switch result {
                case .success(let posted):
                    if posted {
                        self?.store.dispatch(.showOverwriteAlert)
                    } else {
                        self?.store.dispatch(.addLocation)
                    }
                case .failure(let error):
                    self?.store.dispatch(.showErrorAlert(message: error.localizedDescription))
                }
            }
        case .addLocation: command = .presentAddLocationController
        case .showOverwriteAlert: command = .showOverwriteAlert
        case .showErrorAlert(let msg): command = .showErrorAlert(message: msg)
        }

        return (state, command)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _ = mapController?.view

        store = Store(reducer: reducer, initialState: State())
        store.subscribe { [weak self] state, prevState, command in
            self?.stateDidChanged(state: state, previousState: prevState, command: command)
        }

        stateDidChanged(state: store.state, previousState: nil, command: nil)

        store.dispatch(.loadLocations)

    }

    private func stateDidChanged(state: State, previousState: State?, command: Command?) {
        if let command = command {
            switch command {
            case .loadLocations(let handler):
                fetchStudentLocations(completion: handler)
            case .checkPosted(let handler):
                checkCurrentUserLocationPosted(completion: handler)
            case .presentAddLocationController:
                fatalError()
            case .showOverwriteAlert:
                showOverwriteAlert()
            case .showErrorAlert(let msg):
                showErrorAlert(with: msg)
            case .logout:
                AppState.shared.loginedAccount = nil
                dismiss(animated: true, completion: nil)
            }
        }

        if previousState == nil
            || previousState!.dataSource.studentLocations != state.dataSource.studentLocations {

            // update child controllers
            mapController?.store.dispatch(.updateDataSource(state.dataSource))
        }
    }

    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        store.dispatch(.loadLocations)
    }

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        store.dispatch(.checkPosted)
    }

    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        store.dispatch(.logout)
    }
}

private extension TabBarController {
    func fetchStudentLocations(completion: @escaping (Result<[StudentLocation]>) -> Void) {
        let api = ParseAPI.getStudentLocations(limit: nil, skip: nil, order: nil)
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

    func checkCurrentUserLocationPosted(completion: @escaping(Result<Bool>) -> Void) {
        guard let uniqueKey = AppState.shared.loginedAccount?.key else {
            completion(.failure(ErrorType.notLogin))
            return
        }

        HTTPClient.shard.jsonRequest(api: ParseAPI.getStudentLocation(uniqueKey: uniqueKey)) { result in
            let processedResult: Result<Bool> = result.flatMap { json in
                guard
                    let json = json as? [String: Any],
                    let results = json["results"] as? [[String: Any]]
                else {
                    return .failure(ErrorType.unknown)
                }

                return .success(!results.isEmpty)
            }

            DispatchQueue.main.async { completion(processedResult) }
        }
    }

    func showOverwriteAlert() {
        guard let userData = AppState.shared.loginedAccount?.userData else {
            store.dispatch(.showErrorAlert(message: ErrorType.notLogin.localizedDescription))
            return
        }

        let name = "\(userData.firstName) \(userData.lastName)"
        let msg = "User \"\(name)\" Has Already Posted a Student Location. Would You Like to Overwrite Their Locations?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        let overwrite = UIAlertAction(title: "Overwrite", style: .default) { [weak self] _ in
            self?.store.dispatch(.addLocation)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        [overwrite, cancel].forEach(alert.addAction(_:))

        present(alert, animated: true, completion: nil)
    }
}

extension TabBarController {
    struct State: StateType {
        var dataSource = OnTheMapDataSource(studentLocations: [])
    }

    enum Action: ActionType {
        case updateLocations([StudentLocation])
        case loadLocations
        case logout
        case checkPosted
        case addLocation
        case showOverwriteAlert
        case showErrorAlert(message: String)
    }

    enum Command: CommandType {
        case loadLocations(completion: (Result<[StudentLocation]>) -> Void)
        case checkPosted(completion: (Result<Bool>) -> Void)
        case presentAddLocationController
        case showOverwriteAlert
        case showErrorAlert(message: String)
        case logout
    }
}
