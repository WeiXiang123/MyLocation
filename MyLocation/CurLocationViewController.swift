//
//  FirstViewController.swift
//  MyLocation
//
//  Created by WeiXiang on 15/1/5.
//  Copyright (c) 2015年 WeiXiang. All rights reserved.
//

import UIKit
import CoreLocation

class CurLocationViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    let locationManager = CLLocationManager()
    var location:CLLocation?
    
    //error tag
    var updatingLocation = false
    var lastLocationError: NSError?
    
    //geocoder
    let geocoder = CLGeocoder()
    var placemark:CLPlacemark?                  //address results.
    var performingReverseGeocoding = false      // true, if have a place for the coordination
    var lastGeocodingError: NSError?
    
    //limit time for search 
    var timer:NSTimer?
    
    @IBAction func getLocation() {
        let authStatus:CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == CLAuthorizationStatus.Denied || authStatus == CLAuthorizationStatus.Restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        //"Stop" is tapped
        if updatingLocation {
            stopLoactionManager()
        }else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        updateLocationInLabel()
        configGetButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocationInLabel()
        configGetButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("didFailWithError \(error)")
    
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
    
        lastLocationError = error
    
        stopLoactionManager()
        updateLocationInLabel()
        configGetButton()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let newlocation = locations.last as CLLocation
        println("new location is \(newlocation)")
        
        //old time
        if newlocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newlocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newlocation.distanceFromLocation(location)
        }
        
        //first location reading (location is nil) or the new location is more accurate than the previous reading
        if location == nil || location!.horizontalAccuracy > newlocation.horizontalAccuracy {
            lastLocationError = nil
            location = newlocation
            updateLocationInLabel()

        }
        
        //good finished location
        if newlocation.horizontalAccuracy <= locationManager.desiredAccuracy {
            println("*** We're done!")
            stopLoactionManager()
            configGetButton()
    
            if distance < 0 {
                performingReverseGeocoding = false
            }
        }
        
        //geocoder
        if !performingReverseGeocoding {
            println("*** Going to geocode")
            performingReverseGeocoding = true
            geocoder.reverseGeocodeLocation(location, completionHandler: {
                placemarks, error in
                println("***placemark:\(placemarks),error:\(error)")
            
                self.lastGeocodingError = error
            if error == nil && !placemarks.isEmpty {
                self.placemark = placemarks.last as? CLPlacemark
            }else {
                self.placemark = nil
            }
            
            self.performingReverseGeocoding = false
            self.updateLocationInLabel()
            })
        }else if distance < 1.0 {
            let timeInterval = newlocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            if timeInterval > 10 {
                println("*** Force done!")
                
                stopLoactionManager()
                updateLocationInLabel()
                configGetButton()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TagLocation" {
            let navigate = segue.destinationViewController as UINavigationController
            let viewController = navigate.topViewController as LocationDetailsViewController
            viewController.coordinate = location!.coordinate
            viewController.placemark = placemark
        }
    }
    
    func showLocationServicesDeniedAlert() {
        let alertController = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func updateLocationInLabel() {
        
        if let location = self.location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)

            messageLabel.text = ""
            tagButton.hidden = false
            
            //geocoder
            if let placemark = placemark {
                addressLabel.text = stringFromPlacemark(placemark)
            }else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
        }else{
        
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            messageLabel.text = "Tap 'Get My Location' to Start"
            addressLabel.text = ""
            tagButton.hidden = true
        
        //deal with error message
            var statusMessage: String
            if let error = lastLocationError {
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
    }
    
    private func stopLoactionManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            updateLocationInLabel()
            
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    private func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            self.timer = NSTimer(timeInterval: 60, target: self, selector: Selector("DidTimeOut"), userInfo: nil, repeats: false)
                
        }
    }

    private func configGetButton() {
            if updatingLocation {
                getButton!.setTitle("Stop", forState: UIControlState.Normal)
            }else {
                getButton!.setTitle("Get My Location", forState: UIControlState.Normal)
            }
    }
    
    /*
        subThoroughfare is the house number, thoroughfare is the street name, locality is the city, administrativeArea is the state or province, and postalCode is the zip code or postal code.
    */
    private func stringFromPlacemark(placemark: CLPlacemark) -> String {
        
        return  "\(placemark.subThoroughfare) \(placemark.thoroughfare)\n" + "\(placemark.locality) \(placemark.administrativeArea) " + "\(placemark.postalCode)"
    }
    
    private func DidTimeOut() {
        println("*** time out")
        if location == nil {
            stopLoactionManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLocationInLabel()
            configGetButton()
        }
    }
}

