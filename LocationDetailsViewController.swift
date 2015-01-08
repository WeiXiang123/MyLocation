//
//  LocationDetailsViewController.swift
//  MyLocation
//
//  Created by WeiXiang on 15/1/6.
//  Copyright (c) 2015年 WeiXiang. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

extension LocationDetailsViewController: CategoryPickerDelegate {
    
    func categoryPickerDidPickCategory(controller:CategoryPickerViewController) {
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
        navigationController!.popViewControllerAnimated(true)
    }
}

extension LocationDetailsViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        descriptionText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        descriptionText = textView.text
    }
    
}

class LocationDetailsViewController: UITableViewController {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    //coordinate
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark:CLPlacemark?                  //address results.
    
    private let dateFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    //temp var
    var descriptionText = ""
    var categoryName = "No Category"
    
    var managedObjectContext: NSManagedObjectContext!       //coredata
    var date = NSDate()                                     //store cur date
    
    //determine "Tag" or "Edit" mode
    var locationToEdit:Location?{
        didSet{
        if let location = locationToEdit {
            descriptionText = location.locationDescription
            categoryName = location.category
            date = location.date
            coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            placemark = location.placemark
        }
        }
    }
    
    
    @IBAction func done() {
        
       // println("Description is \(descriptionText)")
        let hudView = HudView.hudView(navigationController!.view, animated: true)
        var location:Location
        
        if let tmp = locationToEdit {
            hudView.text = "Update"
            location = tmp
        }else {
            //insert data to core data. "Location" is the entity that named in the DataModel
            location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext) as Location
            hudView.text = "taggled"
        }
        
        location.locationDescription = descriptionText
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        var error:NSError?
        if !managedObjectContext.save(&error) {
            fatalCoreDataError(error)
            return
        }
        
        //animate
        afterDelay(0.6) {
            self.dismissViewControllerAnimated(true, completion: nil)
            }
    }
    
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let locationEdit = locationToEdit {
            title = "Edit Location"
        }
    
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
    
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = formatDate(date)
        
        //touch others to hide the keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    //if not auto size, do it here
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        descriptionTextView.frame.size.width = view.frame.size.width - 30
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            if indexPath.section == 0 && indexPath.row == 0 {
                return 88
            } else if indexPath.section == 2 && indexPath.row == 2 {
                println("**width is \(view.bounds.size.width)")
                addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
                addressLabel.sizeToFit()
                addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
                
                return addressLabel.frame.size.height + 20
            } else {
                return 44
            }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        }else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
        println("select\(indexPath.row)")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategory" {
            let viewController = segue.destinationViewController as CategoryPickerViewController
            viewController.selectedCategoryName = categoryName
            viewController.delegate = self
            
        }
        println("------prepareForSegue;\(categoryName)")
    }
    
    private func stringFromPlacemark(placemark: CLPlacemark) -> String {
            return
                "\(placemark.subThoroughfare) \(placemark.thoroughfare), " + "\(placemark.locality), " +
                "\(placemark.administrativeArea) \(placemark.postalCode)," + "\(placemark.country)"
    }
    
    private func formatDate(date:NSDate)->String {
            return dateFormatter.stringFromDate(date)
    }
    
    private func hideKeyboard(gestureRecognizer:UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if indexPath != nil && indexPath!.section != 0 && indexPath!.row != 0 {
            return
        }
        
        descriptionTextView.resignFirstResponder()
    }

}



