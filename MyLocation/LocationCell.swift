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
    @IBOutlet weak var imagePhoto:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = UIColor.blackColor()
        descriptionLabel.textColor = UIColor.whiteColor()
        descriptionLabel.highlightedTextColor = descriptionLabel.textColor
        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.5)
        addressLabel.highlightedTextColor = addressLabel.textColor

        let selectitonView = UIView(frame: CGRect.zeroRect)
        selectitonView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        selectedBackgroundView = selectitonView

        //circle photo
        imagePhoto.layer.cornerRadius = imagePhoto.bounds.size.width/2
        //makes sure that the image view respects these rounded corners and does not draw outside them
        imagePhoto.clipsToBounds = true
        //moves the separator lines between the cells a bit to the right so there are no lines between the thumbnail images.
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
    }

    //if the view of cell is not autoSize,then do it below
    override func layoutSubviews() {
        super.layoutSubviews()
        //superview property refers to the table view cell’s Content View
        if let subView = superview {
            descriptionLabel.frame.size.width = subView.frame.size.width - descriptionLabel.frame.origin.x - 10
            addressLabel.frame.size.width = subView.frame.size.width - addressLabel.frame.origin.x - 10

        }
    }

    func imageForLocation(location: Location)->UIImage {
        if location.hasPhoto{
            if let image = location.photoImage {
                return image.resizeImageWithBounds(CGSize(width: 52, height: 52))
            }
        }
        return UIImage(named: "No Photo")!
    }

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

        imagePhoto.image = imageForLocation(location)
    }
}
