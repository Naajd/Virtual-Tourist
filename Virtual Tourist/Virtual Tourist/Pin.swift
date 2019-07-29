//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Najd  on 20/11/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import MapKit

extension Pin {
    var coordinate: CLLocationCoordinate2D {
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
    func compare(to coordinate: CLLocationCoordinate2D) -> Bool {
        return (latitude == coordinate.latitude && longitude == coordinate.longitude)
    }
    
    
}
