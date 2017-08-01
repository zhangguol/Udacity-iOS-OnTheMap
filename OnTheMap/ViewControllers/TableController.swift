//
//  TableController.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/27/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import UIKit

class TableController: UIViewController, StoreSubscriber {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    var parentController: TabBarController? {
        return tabBarController as? TabBarController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
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

    private func stateDidChanged(state: TabBarController.State, previousState: TabBarController.State?, command: TabBarController.Command?) {
        if previousState == nil
            || previousState!.dataSource != state.dataSource {

            tableView.dataSource = state.dataSource
            tableView.reloadData()
        }

        if previousState == nil
            || previousState!.isLoading != state.isLoading {

            (state.isLoading ? loadingIndicator.startAnimating : loadingIndicator.stopAnimating)()
        }
    }
}

extension TableController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let location = parentController?.store.state.dataSource.studentLocations[indexPath.row] else { return }

        guard let url = URL(string: location.mediaURL) else {
            showErrorAlert(with: ErrorType.invalidURL.localizedDescription)
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
