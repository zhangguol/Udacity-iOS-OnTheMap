//
//  UdacityAccount.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/10/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import Foundation

struct UdacityAccount {
    let key: String

    var userData: UserData?
}

extension UdacityAccount {
    init?(json: [String: Any]) {
        guard let key = json["key"] as? String else {
            return nil
        }
        self.key = key
    }
}
