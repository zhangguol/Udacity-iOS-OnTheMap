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

extension OnTheMapDataSource: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: self).CellIdentifier)
                    ?? UITableViewCell(style: .subtitle, reuseIdentifier: type(of: self).CellIdentifier)

        let location = studentLocations[indexPath.row]
        
        cell.imageView?.image = UIImage(named: "icon_pin")
        cell.textLabel?.text = location.fullName
        cell.detailTextLabel?.text = location.mediaURL
        
        return cell
    }

    private static let CellIdentifier = "LocationCell"
}
