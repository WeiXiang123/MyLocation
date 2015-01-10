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
    @NSManaged var photoID:NSNumber?

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

    var hasPhoto: Bool {
        return photoID != nil
    }

    var photoPath: String {
        assert(photoID != nil, "No photo ID seted!")
        let fileName = "Photo-\(photoID!.integerValue).jpg"
        return applicationDocumentsDirectory.stringByAppendingPathComponent(fileName)
    }

    var photoImage:UIImage? {
        return UIImage(contentsOfFile: photoPath)
    }

    class func nextPhotoID()->Int {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let currentID = userDefault.integerForKey("photoID")
        userDefault.setInteger(currentID + 1, forKey: "photoID")
        userDefault.synchronize()

        return currentID
    }

    func removePhotoFile() {
        if hasPhoto {
            let fileManage = NSFileManager.defaultManager()
            if fileManage.fileExistsAtPath(photoPath) {
                var error: NSError?
                if !fileManage.removeItemAtPath(photoPath, error: &error) {
                    println("remove photo failed.\(error!)")
                }
            }
        }
    }


}













