//
//  MyTabBarController.swift
//  MyLocation
//
//  Created by WeiXiang on 15/1/10.
//  Copyright (c) 2015年 WeiXiang. All rights reserved.
//

import Foundation
import UIKit

class MyTabBarController: UITabBarController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return nil
    }
}