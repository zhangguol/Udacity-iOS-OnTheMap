//
//  OnTheMapDataSource.swift
//  OnTheMap
//
//  Created by Boxuan Zhang on 7/26/17.
//  Copyright © 2017 Boxuan hang. All rights reserved.
//

import Foundation

class OnTheMapDataSource: NSObject {

    init(studentLocations: [StudentLocation] = []) {
        self.studentLocations = studentLocations
    }
    
     let studentLocations: [StudentLocation]
}
