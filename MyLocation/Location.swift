//
//  MyLocation.swift
//  MyLocation
//
//  Created by WeiXiang on 15/1/7.
//  Copyright (c) 2015年 WeiXiang. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import MapKit

class Location: NSManagedObject,MKAnnotation {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var date: NSDate
    @NSManaged var locationDescription: String
    @NSManaged var category: String
    @NSManaged var placemark:CLPlacemark?

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String! {
        if locationDescription.isEmpty {
            return "no descrioption here!"
        }else {
            return locationDescription
        }
    }
    
    var subtitle: String!  {
        return category
    }
}
