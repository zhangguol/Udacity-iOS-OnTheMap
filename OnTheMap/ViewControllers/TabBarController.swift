//
//  TabBarController.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/26/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, StoreSubscriber {

    var mapController: MapViewController? {
        return viewControllers?[0] as? MapViewController
    }

    var tableController: TableController? {
        return viewControllers?[1] as? TableController
    }

    var store: Store<Action, State, Command>!

    lazy var reducer: (State, Action) -> (state: State, command: Command?) = {
        [weak self] (state: State, action: Action) in

        var state = state
        var command: Command? = nil

        switch action {
        case .updateLocations(let locations):
            state.dataSource = OnTheMapDataSource(studentLocations: locations)
        case .updateLoadingState(let isLoading):
            state.isLoading = isLoading
        case .loadLocations:
            command = .loadLocations { result in
                self?.store.dispatch(.updateLoadingState(isLoading: false))
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
                case .success(let exsitingLocation):
                    if let exsitingLocation = exsitingLocation {
                        self?.store.dispatch(.showOverwriteAlert(locationToBeOverwritten: exsitingLocation))
                    } else {
                        do {
                            guard let strongSelf = self else { break }
                            let newLocation = try strongSelf.generateNewStudentLocation()

                            self?.store.dispatch(.addLocation(newLocation))
                        } catch let error {
                            self?.store.dispatch(.showErrorAlert(message: error.localizedDescription))
                        }
                    }
                case .failure(let error):
                    self?.store.dispatch(.showErrorAlert(message: error.localizedDescription))
                }
            }
        case .addLocation(let location):
            command = .presentAddLocationController(forLocation: location)
        case .showOverwriteAlert(let location): command = .showOverwriteAlert(locationToBeOverwritten: location)
        case .showErrorAlert(let msg): command = .showErrorAlert(message: msg)
        }

        return (state, command)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        store = Store(reducer: reducer, initialState: State())
        store.subscribe(self) { [weak self] state, prevState, command in
            self?.stateDidChanged(state: state, previousState: prevState, command: command)
        }

        stateDidChanged(state: store.state, previousState: nil, command: nil)


    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        store.dispatch(.loadLocations)
    }

    private func stateDidChanged(state: State, previousState: State?, command: Command?) {
        if let command = command {
            switch command {
            case .loadLocations(let handler):
                store.dispatch(.updateLoadingState(isLoading: true))
                loadLocations(completion: handler)
            case .checkPosted(let handler):
                checkCurrentUserLocationPosted(completion: handler)
            case .presentAddLocationController(let location):
                let vc = AddLocationController.initFromStoryboard(studentLoaction: location)
                navigationController?.pushViewController(vc, animated: true)
            case .showOverwriteAlert(let locationToBeOverwritten):
                showOverwriteAlert(locationToBeOverwritten: locationToBeOverwritten)
            case .showErrorAlert(let msg):
                showErrorAlert(with: msg)
            case .logout:
                AppState.shared.loginedAccount = nil
                dismiss(animated: true, completion: nil)
            }
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
    func loadLocations(completion: @escaping (Result<[StudentLocation]>) -> Void) {
        let group = DispatchGroup()

        var error: Error?
        group.enter()
        var locations: [StudentLocation] = []
        fetchStudentLocations { result in
            switch result {
            case .success(let ls): locations = ls
            case .failure(let e): error = e
            }
            group.leave()
        }

        group.enter()
        var selfLocation: StudentLocation? = nil
        checkCurrentUserLocationPosted { result in
            switch result {
            case .success(let location): selfLocation = location
            default: break
            }
            group.leave()
        }

        group.notify(queue: .main) {
            if let error = error {
                completion(.failure(error))
                return
            }

            selfLocation.map { locations.insert($0, at: 0) }
            
            completion(.success(locations))
        }
    }
    
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

    func checkCurrentUserLocationPosted(completion: @escaping(Result<StudentLocation?>) -> Void) {
        guard let uniqueKey = AppState.shared.loginedAccount?.key else {
            completion(.failure(ErrorType.notLogin))
            return
        }

        HTTPClient.shard.jsonRequest(api: ParseAPI.getStudentLocation(uniqueKey: uniqueKey)) { result in
            let processedResult: Result<StudentLocation?> = result.flatMap { json in
                guard
                    let json = json as? [String: Any],
                    let results = json["results"] as? [[String: Any]]
                else {
                    return .failure(ErrorType.unknown)
                }

                return .success(results.first.flatMap(StudentLocation.init(json:)))
            }

            DispatchQueue.main.async { completion(processedResult) }
        }
    }

    func showOverwriteAlert(locationToBeOverwritten: StudentLocation) {
        guard let userData = AppState.shared.loginedAccount?.userData else {
            store.dispatch(.showErrorAlert(message: ErrorType.notLogin.localizedDescription))
            return
        }

        let name = "\(userData.firstName) \(userData.lastName)"
        let msg = "User \"\(name)\" Has Already Posted a Student Location. Would You Like to Overwrite Their Locations?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        let overwrite = UIAlertAction(title: "Overwrite", style: .default) { [weak self] _ in
            self?.store.dispatch(.addLocation(locationToBeOverwritten))
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        [overwrite, cancel].forEach(alert.addAction(_:))

        present(alert, animated: true, completion: nil)
    }

    func generateNewStudentLocation() throws -> StudentLocation {
        guard let account = AppState.shared.loginedAccount,
            let userData = account.userData else {
            throw ErrorType.notLogin
        }

        return StudentLocation(
            objectID: nil,
            uniqueKey: account.key,
            firstName: userData.firstName,
            lastName: userData.lastName,
            mapString: "",
            mediaURL: "",
            latitude: 0.0,
            longitude: 0.0
        )
    }
}

extension TabBarController {
    struct State: StateType {
        var dataSource = OnTheMapDataSource(studentLocations: [])

        var isLoading = false
    }

    enum Action: ActionType {
        case updateLocations([StudentLocation])
        case updateLoadingState(isLoading: Bool)
        case loadLocations
        case logout
        case checkPosted
        case addLocation(StudentLocation)
        case showOverwriteAlert(locationToBeOverwritten: StudentLocation)
        case showErrorAlert(message: String)
    }

    enum Command: CommandType {
        case loadLocations(completion: (Result<[StudentLocation]>) -> Void)
        case checkPosted(completion: (Result<StudentLocation?>) -> Void)
        case presentAddLocationController(forLocation: StudentLocation)
        case showOverwriteAlert(locationToBeOverwritten: StudentLocation)
        case showErrorAlert(message: String)
        case logout
    }
}
