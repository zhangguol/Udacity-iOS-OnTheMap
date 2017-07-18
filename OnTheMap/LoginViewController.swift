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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard
            let username = emailTextField.text,
            let password = passwordTextField.text,
            !username.isEmpty && !password.isEmpty
        else {
            showErrorAlert(with: "Empty Email or Password")
            return
        }

        loadingIndicator.startAnimating()
        HTTPClient.shard.jsonRequest(
            api: UdacityAPI.postSession(username: username, password: password)
        ) { result in
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                switch result {
                case .success(let json):
                    guard let json = json as? [String: Any] else {
                        self.showErrorAlert(with: "Unknow Error")
                        return
                    }

                    if let accountJSON = json["account"] as? [String: Any],
                        let account = UdacityAccount(json: accountJSON) {
                        AppState.shared.loginedAccount = account
                        // TODO: Jump to next view controller
                    } else if let error = json["error"] as? String {
                        self.showErrorAlert(with: error)
                    } else {
                        self.showErrorAlert(with: "Unknow Error")
                    }

                    print("success")
                case .failure(let error):
                    self.showErrorAlert(with: error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        let url = URL(string: "https://www.udacity.com/account/auth#!/signup")
        url.map { UIApplication.shared.open($0, options: [:], completionHandler: nil) }
    }
}
