//
//  MapViewController.swift
//  MyLocation
//
//  Created by WeiXiang on 15/1/9.
//  Copyright (c) 2015年 WeiXiang. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class MapViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext!{
        didSet{
            NSNotificationCenter.defaultCenter().addObserverForName(MyManagedObjectContextSaveDidFailNotification, object: managedObjectContext, queue: NSOperationQueue.mainQueue()){
                notification in
                if self.isViewLoaded(){
                    self.updateLocations()
                }
            }
        }
    }
    
    var locations = [Location]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
        
        if !locations.isEmpty {
            showLocations()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showLocations() {
        let region = regionForAnnotations(locations)
        mapView.setRegion(region, animated: true)
    }

    @IBAction func showUser(sender: AnyObject) {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditLocation" {
            let navigateController = segue.destinationViewController as UINavigationController
            let viewController = navigateController.topViewController as LocationDetailsViewController
            viewController.managedObjectContext = managedObjectContext
            
            let button = sender as UIButton
            let location = locations[button.tag]
            viewController.locationToEdit = location

        }
    }
    
    func updateLocations() {
        //1. init fetch, get entity
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        
        var error:NSError?
        let foundObjs = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
        //2. update map view
        if foundObjs == nil {
            fatalCoreDataError(error)
            return
        }
        
        mapView.removeAnnotations(locations)
        locations = foundObjs as [Location]
        mapView.addAnnotations(locations)
    }
    
    func regionForAnnotations(annotations:[MKAnnotation])->MKCoordinateRegion {
        var region: MKCoordinateRegion
        
        switch annotations.count {
        case 0:
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        case 1:
            let location = annotations[0]
            region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
        default:
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            
            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude)/2, longitude: bottomRightCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude)/2)
            
            let extrSpace = 1.1
            let span = MKCoordinateSpan(latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extrSpace, longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extrSpace)
            
            region = MKCoordinateRegionMake(center, span)
        }
        
        return mapView.regionThatFits(region)
    }
    
    func showLocationDetails(sender: UIButton){
        performSegueWithIdentifier("EditLocation", sender: sender)
    }

}

extension MapViewController:MKMapViewDelegate {
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        //1. filter data type
        if annotation is Location {
            //2. dequence view as table view(add a button)
            let indentfier = "annotationView"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(indentfier) as MKPinAnnotationView!
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: indentfier)
                
                annotationView.enabled = true
                annotationView.canShowCallout = true
                annotationView.animatesDrop = false
                annotationView.pinColor = MKPinAnnotationColor.Green
                
                let rightButton = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
                rightButton.addTarget(self, action: Selector("showLocationDetails:"), forControlEvents: UIControlEvents.TouchUpInside)
                annotationView.rightCalloutAccessoryView = rightButton
            }else{
                annotationView.annotation = annotation
            }
            
            //3. set button tag for the array index
            let button = annotationView.rightCalloutAccessoryView as UIButton
            if let index = find(locations, annotation as Location) {
                button.tag = index
            }
            
            return annotationView
        }
        return nil
        
    }
}

extension MapViewController:UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}


