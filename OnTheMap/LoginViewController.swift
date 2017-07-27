//
//  ViewController.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 6/29/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!

    var store: Store<Action, State, Command>!
    
    lazy var reducer: (State, Action) -> (state: State, command: Command?) = {
        [weak self] (state: State, action: Action) in

        var state = state
        var command: Command? = nil

        switch action {
        case .updateUsername(let username):
            state.username = username
        case .updatePassword(let pwd):
            state.password = pwd
        case .stopLoadingIndicator:
            state.isLoading = false
        case .login:
            state.isLoading = true
            command = Command.login { result in
                self?.store.dispatch(.stopLoadingIndicator)
                switch result {
                case .success(let account):
                    self?.store.dispatch(.updateAppStateAccount(account))
                    self?.store.dispatch(.fetchUserData)
                case .failure(let error):
                    self?.store.dispatch(.showErrorAlert(message: error.localizedDescription))
                }
            }
        case .signup: command = Command.signup
        case .showErrorAlert(let msg): command = .showErrorAlert(message: msg)
        case .updateAppStateAccount(let account): command = .updateAppStateAccount(account)
        case .updateAppStateUserData(let userData): command = .updateAppStateUserData(userData)
        case .goToNextView: command = .goToNextView
        case .fetchUserData:
            state.isLoading = true
            command = .fetchUserData { result in
                self?.store.dispatch(.stopLoadingIndicator)
                switch result {
                case .success(let userData):
                    self?.store?.dispatch(.updateAppStateUserData(userData))
                    self?.store?.dispatch(.updateUsername(username: ""))
                    self?.store?.dispatch(.updatePassword(password: ""))
                    self?.store?.dispatch(.goToNextView)
                case .failure(let error):
                    self?.store.dispatch(.showErrorAlert(message: error.localizedDescription))
                }
            }
        }

        return (state, command)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        store = Store(
            reducer: reducer,
            initialState: State(username: "", password: "", isLoading: false)
        )
        
        store.subscribe { [weak self] state, prevState, command in
            self?.stateDidChanged(state: state, previousState: prevState, command: command)
        }
        
        stateDidChanged(state: store.state, previousState: nil, command: nil)
    }
    
    private func stateDidChanged(state: State, previousState: State?, command: Command?) {
        if let command = command {
            switch command {
            case let .login(handler):
                login(username: state.username, password: state.password, completion: handler)
            case .showErrorAlert(let msg):
                showErrorAlert(with: msg)
            case .signup: signup()
            case .updateAppStateAccount(let account):
                AppState.shared.loginedAccount = account
            case .updateAppStateUserData(let userData):
                AppState.shared.loginedAccount?.userData = userData
            case .goToNextView:
                performSegue(withIdentifier: "showOnTheMap", sender: self)
            case .fetchUserData(let handler):
                fetchUserData(completion: handler)
            }
        }
        
        if previousState == nil
            || previousState!.username != state.username
            || previousState!.password != state.password {

            emailTextField.text = state.username
            passwordTextField.text = state.password
            
            let enable = !state.username.isEmpty && !state.password.isEmpty
            loginButton.isEnabled = enable
            loginButton.backgroundColor = enable ? UIColor(red:0.13, green:0.71, blue:0.88, alpha:1.00) : .gray
        }

        if previousState == nil || previousState!.isLoading != state.isLoading {
            [
                true: loadingIndicator.startAnimating,
                false: loadingIndicator.stopAnimating
            ][state.isLoading]!()
        }
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        store.dispatch(.login)
    }
    
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        store.dispatch(.signup)
    }
    
    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        let value = sender.text ?? ""
        let action: Action = {
            switch sender {
            case emailTextField: return .updateUsername(username: value)
            case passwordTextField: return .updatePassword(password: value)
            default: fatalError()
            }
        }()
        
        store.dispatch(action)
    }

    private func signup() {
        let url = URL(string: "https://www.udacity.com/account/auth#!/signup")
        url.map { UIApplication.shared.open($0, options: [:], completionHandler: nil) }
    }
    
    private func login(username: String, password: String, completion: @escaping (Result<UdacityAccount>) -> Void) {
        HTTPClient.shard.jsonRequest(
            api: UdacityAPI.postSession(username: username, password: password)
        ) { result in
            DispatchQueue.main.async {
                completion(result.flatMap { json in
                    guard let json = json as? [String: Any] else {
                        return .failure(ErrorType.unknown)
                    }

                    if let accountJSON = json["account"] as? [String: Any],
                        let account = UdacityAccount(json: accountJSON) {
                        return .success(account)
                    } else if let error = json["error"] as? String {
                        return .failure(ErrorType.serverSideError(msg: error))
                    } else {
                        return .failure(ErrorType.unknown)
                    }
                })
            }
        }
    }

    private func fetchUserData(completion: @escaping (Result<UserData>) -> Void) {
        guard let userID = AppState.shared.loginedAccount?.key else {
            completion(.failure(ErrorType.loginError))
            return
        }
        HTTPClient.shard.jsonRequest(api: UdacityAPI.getPublicUserData(userID: userID)) { result in
            let processedResult: Result<UserData> = result.flatMap { json in
                guard
                    let json = json as? [String: Any],
                    let userJSON = json["user"] as? [String: Any],
                    let userData = UserData(json: userJSON)
                else {
                    return .failure(ErrorType.unknown)
                }

                return .success(userData)
            }

            DispatchQueue.main.async { completion(processedResult) }
        }
    }
}

extension LoginViewController {
    struct State: StateType {
        var username: String
        var password: String

        var isLoading: Bool
    }

    enum Action: ActionType {
        case updateUsername(username: String)
        case updatePassword(password: String)
        case login
        case signup
        case showErrorAlert(message: String)
        case stopLoadingIndicator
        case updateAppStateAccount(UdacityAccount)
        case updateAppStateUserData(UserData)
        case goToNextView
        case fetchUserData
    }

    enum Command: CommandType {
        case signup
        case login(completion: (Result<UdacityAccount>) -> Void)
        case showErrorAlert(message: String)
        case updateAppStateAccount(UdacityAccount)
        case updateAppStateUserData(UserData)
        case goToNextView
        case fetchUserData(completion: (Result<UserData>) -> Void)
    }
}
