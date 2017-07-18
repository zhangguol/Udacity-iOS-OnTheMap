//
//  AlertPresentable.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/10/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import UIKit

extension UIViewController {
    func showErrorAlert(with errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }
}
