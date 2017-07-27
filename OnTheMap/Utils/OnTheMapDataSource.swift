//
//  OnTheMapDataSource.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/26/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import Foundation
import MapKit

class OnTheMapDataSource: NSObject {

    init(studentLocations: [StudentLocation] = []) {
        self.studentLocations = studentLocations
    }
    
    let studentLocations: [StudentLocation]

    lazy var studentLocationAnnotations: [StudentLocationAnnotation] = {
        return self.studentLocations.map { $0.generateAnnotation() }
    }()
}
