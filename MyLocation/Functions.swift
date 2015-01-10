//
//  Functions.swift
//  MyLocation
//
//  Created by WeiXiang on 15/1/7.
//  Copyright (c) 2015年 WeiXiang. All rights reserved.
//

import Foundation
import Dispatch
import UIKit

func afterDelay(second:Float, closure:()->()) {
    let durationTime = Int64(second * Float(NSEC_PER_SEC))
    let when = dispatch_time(DISPATCH_TIME_NOW, durationTime)
    
    dispatch_after(when, dispatch_get_main_queue(), closure)
    
}

let applicationDocumentsDirectory:String = {
    let paths =  NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) as [String]
    return paths[0]
}()