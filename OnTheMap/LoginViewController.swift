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
            return
        }
        
        HTTPClient.shard.jsonRequest(
            api: UdacityAPI.postSession(username: username, password: password)
        ) { result in
           print(result)
        }
    }
    
    @IBAction func signupButtonTapped(_ sender: UIButton) {}
}
