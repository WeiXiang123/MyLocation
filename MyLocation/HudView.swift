//
//  HudView.swift
//  MyLocation
//
//  Created by WeiXiang on 15/1/6.
//  Copyright (c) 2015年 WeiXiang. All rights reserved.
//

import UIKit

class HudView: UIView {

    var text = ""
    
    class func hudView(view:UIView,animated:Bool)->HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.opaque = false
        
        view.addSubview(hudView)
        view.userInteractionEnabled = false
        //hudView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        hudView.showAinmate(animated)
        
        return hudView
    }
    
    override func drawRect(rect: CGRect) {
        let width:CGFloat = 96
        let height:CGFloat = 96
        
        let boxRect = CGRect(x: round((bounds.size.width - width)/2), y: round((bounds.size.height - height)/2), width: width, height: height)
            
        let roundRect = UIBezierPath(roundedRect: boxRect, cornerRadius:10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundRect.fill()
        
        //image '√'
        let image = UIImage(named: "Checkmark")
        let point = CGPoint(x: center.x - image!.size.width/2, y: center.y - image!.size.height/2 - boxRect.size.height/8)
        image!.drawAtPoint(point)
            
        //label
        let attribs = [
            NSFontAttributeName: UIFont.systemFontOfSize(16.0),
            NSForegroundColorAttributeName: UIColor.whiteColor()
            ]
            
        let textSize = text.sizeWithAttributes(attribs)
        let textPoint = CGPoint(
                x: center.x - round(textSize.width / 2),
                y: center.y - round(textSize.height / 2) + boxRect.size.height / 4)
        text.drawAtPoint(textPoint, withAttributes: attribs)
    }
    
    func showAinmate(animated: Bool) {
        if animated {
            //init
            alpha = 0
            transform = CGAffineTransformMakeScale(1.3, 1.3)
            
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(0), animations: {
                self.alpha = 1
                self.transform = CGAffineTransformIdentity
            }, completion: nil)
            
            /*
            UIView.animateWithDuration(0.5, animations: {
            self.alpha = 1
            self.transform = CGAffineTransformIdentity
                })
            */
            
        }
    }


}
