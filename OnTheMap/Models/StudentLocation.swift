//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/5/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import Foundation

struct StudentLocation {
    let objectID: String?
    var uniqueKey: String?

    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String

    let latitude: Double
    let longitude: Double
}

extension StudentLocation {
    init?(json: [String: Any]) {
        guard
            let objectID = json["objectId"] as? String,
            let firstName = json["firstName"] as? String,
            let lastName = json["lastName"] as? String,
            let mapString = json["mapString"] as? String,
            let mediaURL = json["mediaURL"] as? String,
        
            let latitude = json["latitude"] as? Double,
            let longitude = json["longitude"] as? Double
        else { return nil }

        self.objectID = objectID
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.latitude = latitude
        self.longitude = longitude

        self.uniqueKey = json["uniqueKey"] as? String
    }

    func toJSON(withID: Bool = true) -> [String: Any] {
        var json = [String: Any]()
        
        if withID {
            json["objectId"] = objectID
        }
        
        json["uniqueKey"] = uniqueKey
        json["firstName"] = firstName
        json["lastName"] = lastName
        json["mapString"] = mapString
        json["mediaURL"] = mediaURL
        json["latitude"] = latitude
        json["longitude"] = longitude

        return json
    }
}
