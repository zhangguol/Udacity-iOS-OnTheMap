//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/5/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import Foundation
import MapKit

struct StudentLocation {
    let objectID: String?
    var uniqueKey: String?

    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String

    let latitude: Double
    let longitude: Double

    var fullName: String { return "\(firstName) \(lastName)"}
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

extension StudentLocation: Equatable {
    static func == (lhs: StudentLocation, rhs: StudentLocation) -> Bool {
        switch (lhs.objectID, rhs.objectID) {
        case let (.some(l), .some(r)): return l == r
        default: return false
        }
    }
}

extension StudentLocation {
    func generateAnnotation() -> StudentLocationAnnotation {
        return StudentLocationAnnotation(
            latitude: latitude,
            longitude: longitude,
            title: fullName,
            subtitle: mediaURL)
    }
}

class StudentLocationAnnotation: NSObject, MKAnnotation {

    init(latitude: Double, longitude: Double, title: String, subtitle: String) {
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.title = title
        self.subtitle = subtitle
    }
    
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
}
