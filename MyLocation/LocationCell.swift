//
//  LocationCell.swift
//  MyLocation
//
//  Created by WeiXiang on 15/1/8.
//  Copyright (c) 2015年 WeiXiang. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel:UILabel!
    @IBOutlet weak var addressLabel:UILabel!

    func configureForLocation(location: Location) {
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "None description"
        }else {
            descriptionLabel.text = location.locationDescription
        }
        
        if let placeMark = location.placemark {
            addressLabel.text = "\(placeMark.locality)"
        }else {
            addressLabel.text = String(format: "lat: %.8f, Long:%.8f", location.latitude,location.longitude)
        }
    }
}
