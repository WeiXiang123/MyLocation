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

class Location: NSManagedObject {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var date: NSDate
    @NSManaged var locationDescription: String
    @NSManaged var category: String
    @NSManaged var placemark:CLPlacemark?

}
