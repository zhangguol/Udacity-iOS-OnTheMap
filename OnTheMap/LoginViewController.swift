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
        case .updateUsername(let username): state.username = username
        case .updatePassword(let pwd): state.password = pwd
        case .login: command = Command.login { result in
            switch result {
            case .success(let account):
                self?.store.dispatch(.loginSuccess(account: account))
            case .failure(let error):
                self?.store.dispatch(.loginFailed(message: error.localizedDescription))
            }
        }
        case .signup: command = Command.signup
        case .clearCredentials:
            self?.store.dispatch(.updateUsername(username: ""))
            self?.store.dispatch(.updatePassword(password: ""))
        case .loginSuccess(let account): command = Command.loginSuccess(account: account)
        case .loginFailed(let msg): command = Command.loginFailed(message: msg)
        }

        return (state, command)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        store = Store(
            reducer: reducer,
            initialState: State(username: "", password: "")
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
                loadingIndicator.startAnimating()
                login(username: state.username, password: state.password, completion: handler)
            case .loginSuccess(let account):
                loadingIndicator.stopAnimating()
                didLogin(with: account)
            case .loginFailed(message: let msg):
                loadingIndicator.stopAnimating()
                showErrorAlert(with: msg)
            case .signup: signup()
            }
        }
        
        if previousState == nil
            || previousState!.username != state.username
            || previousState!.password != state.password {
          
            let enable = !state.username.isEmpty && !state.password.isEmpty
            loginButton.isEnabled = enable
            loginButton.backgroundColor = enable ? UIColor(red:0.13, green:0.71, blue:0.88, alpha:1.00) : .gray
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

    private func didLogin(with account: UdacityAccount) {
        store.dispatch(.clearCredentials)

        AppState.shared.loginedAccount = account
        performSegue(withIdentifier: "showOnTheMap", sender: self)
    }
}

extension LoginViewController {
    struct State: StateType {
        var username: String
        var password: String
    }

    enum Action: ActionType {
        case updateUsername(username: String)
        case updatePassword(password: String)
        case login
        case signup
        case loginSuccess(account: UdacityAccount)
        case loginFailed(message: String)
        case clearCredentials
    }

    enum Command: Commandtype {
        case signup
        case login(completion: (Result<UdacityAccount>) -> Void)
        case loginSuccess(account: UdacityAccount)
        case loginFailed(message: String)
    }
}

extension LoginViewController {
    enum ErrorType: Error {
        case serverSideError(msg: String)
        case unknown

        var localizedDescription: String {
            switch self {
            case .serverSideError(let msg): return msg
            case .unknown: return "Unknown Error"
            }
        }
    }
}
