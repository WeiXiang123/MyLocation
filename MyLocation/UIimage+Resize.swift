//
//  UIimage+Resize.swift
//  MyLocation
//
//  Created by WeiXiang on 15/1/10.
//  Copyright (c) 2015年 WeiXiang. All rights reserved.
//

import UIKit

/*
*Aspect Fit keeps the entire image visible while Aspect Fill fills up the entire rectangle and may cut off parts of the sides. In other words, Aspect Fit scales to the longest side but Aspect Fill scales to the shortest side.
*/

extension UIImage {

    func resizeImageWithBounds(bouds:CGSize)->UIImage {
        //1. aspect fit
        let horizonRatio = bouds.width / size.width
        let verticalRatio = bouds.height / size.height
        let ratio = min(horizonRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        //2. draw new image
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        drawInRect(CGRect(origin: CGPoint.zeroPoint, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}