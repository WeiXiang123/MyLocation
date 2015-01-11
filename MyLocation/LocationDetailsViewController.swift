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

extension LocationDetailsViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func takePhotoWithCamera() {
        let imagePicker = MyImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    func choosePhotoFromLibrary() {
        let imagePicker = MyImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        image = info[UIImagePickerControllerEditedImage] as UIImage?
        if let image = image {
            showImageViewPhoto(image)
        }

        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            showPhotoMenu()
        }else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil)
        alertController.addAction(cancelAction)
        
        let takePhtoAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: {_ in
        self.takePhotoWithCamera()
        })
        alertController.addAction(takePhtoAction)
        
        let chooseFromLibrary = UIAlertAction(title: "Choose From Library", style: UIAlertActionStyle.Default, handler:{
            _ in self.choosePhotoFromLibrary()
        })
        alertController.addAction(chooseFromLibrary)
        
        presentViewController(alertController, animated: true, completion: nil)
    }

    func showImageViewPhoto(image:UIImage) {
        imageViewPhoto.hidden = false
        imageViewPhoto.image = image
        imageViewPhoto.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
        addPhotoLabel.hidden = true
    }
   
}

class LocationDetailsViewController: UITableViewController {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var imageViewPhoto: UIImageView!
    
    //coordinate
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark:CLPlacemark?                  //address results.
    var image:UIImage?
    
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

    //for home button
    var observer: AnyObject?

    deinit {
        println("*** deinit \(self)")
        NSNotificationCenter.defaultCenter().removeObserver(observer!)
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
            location.photoID = nil
        }
        
        location.locationDescription = descriptionText
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark

        // photo
        if let image = image {
            //1. set newPhotoId
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID()
            }
            //2. convert to jpg
            let data = UIImageJPEGRepresentation(image, 0.5)
            //3. save file
            var error:NSError?
            if !data.writeToFile(location.photoPath, options: NSDataWritingOptions.DataWritingAtomic, error: &error) {
                println("Write photo error.\(error)")
            }
            println("+++++\(location.photoPath)")

        }

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

            if locationEdit.hasPhoto {
                if let image = locationEdit.photoImage {
                    showImageViewPhoto(image)
                }
            }
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

        //add listen for the home button
        listenForBackgroudNotification()

        //set color
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.4)
        tableView.indicatorStyle = UIScrollViewIndicatorStyle.White

        descriptionTextView.backgroundColor = UIColor.blackColor()
        descriptionTextView.textColor = UIColor.whiteColor()

        addPhotoLabel.textColor = UIColor.blackColor()
        addPhotoLabel.highlightedTextColor = UIColor.whiteColor()

        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.5)
        addressLabel.highlightedTextColor = addressLabel.textColor
        
    }
    
    //if not auto size, do it here
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        descriptionTextView.frame.size.width = view.frame.size.width - 30
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        switch (indexPath.section,indexPath.row) {
        case (0,0):
            return 88
        case (1,_):
            return imageViewPhoto.hidden ? 44 : 280
        case (2,2):
            println("**width is \(view.bounds.size.width)")
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15

            return addressLabel.frame.size.height + 20
        default:
            return 44

        }
        /*
            if indexPath.section == 0 && indexPath.row == 0 {
                return 88
            } else if indexPath.section == 2 && indexPath.row == 2 {
                println("**width is \(view.bounds.size.width)")
                addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
                addressLabel.sizeToFit()
                addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
                
                return addressLabel.frame.size.height + 20
            }else if indexPath.section == 1{
                if imageViewPhoto.hidden {
                    return 44
                }
                return 280

            }else {
                return 44
            }
        */
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
        }else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated:true)
            pickPhoto()
        }
        
        println("select\(indexPath.row)")
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.blackColor()

        if let mainLabel = cell.textLabel {
            mainLabel.textColor = UIColor.whiteColor()
            mainLabel.highlightedTextColor = mainLabel.textColor
        }

        if let subLabel = cell.detailTextLabel {
            subLabel.textColor = UIColor.whiteColor()
            subLabel.highlightedTextColor = subLabel.textColor
        }

        let selectedView = UIView(frame: CGRect.zeroRect)
        selectedView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        cell.selectedBackgroundView = selectedView

        if indexPath.row == 2 {
            let addressLabel = tableView.viewWithTag(100) as UILabel
            addressLabel.textColor = UIColor.whiteColor()
            addressLabel.highlightedTextColor = addressLabel.textColor
        }
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
    
    func hideKeyboard(gestureRecognizer:UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        
        descriptionTextView.resignFirstResponder()
    }

    func listenForBackgroudNotification() {
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()){ [weak self]_ in
            if let strongSelf = self {

                if strongSelf.presentedViewController != nil {
                    strongSelf.dismissViewControllerAnimated(false, completion: nil)
                }

                strongSelf.descriptionTextView.resignFirstResponder()
            }
        }
    }



}



