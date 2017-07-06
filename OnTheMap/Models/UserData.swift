//
//  UserData.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/6/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import Foundation

struct UserData {

    let firstName: String
    let lastName: String
    let emailAddress: String
}

extension UserData {

    init?(json: [String: Any]) {
        guard
            let firstName = json["first_name"] as? String,
            let lastName = json["last_name"] as? String,
            let email = json["email"] as? [String: Any],
            let emailAddress = email["address"] as? String
        else { return nil }

        self.firstName = firstName
        self.lastName = lastName
        self.emailAddress = emailAddress
    }
}
