//
//  LocationsViewController.swift
//  MyLocation
//
//  Created by WeiXiang on 15/1/8.
//  Copyright (c) 2015年 WeiXiang. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext!
    
    lazy var fetchedResultsController:NSFetchedResultsController = {
        //1. init fetch obj
        let request = NSFetchRequest()
        //2. config entity,sort
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext)
        request.entity = entity
        let sortDescriptor1 = NSSortDescriptor(key: "category", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        request.fetchBatchSize = 20
        
        let fetchResultController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "category", cacheName: "Location")
        fetchResultController.delegate = self
        
        return fetchResultController
        
    }()
    
    deinit{
        fetchedResultsController.delegate = nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performFetch()
        navigationItem.rightBarButtonItem = editButtonItem() //this is the edit mode(delete)
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell") as LocationCell
        let location = fetchedResultsController.objectAtIndexPath(indexPath) as Location
        cell.configureForLocation(location)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //1. op type
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let location = fetchedResultsController.objectAtIndexPath(indexPath) as Location
            location.removePhotoFile()
            managedObjectContext.deleteObject(location)
            
            //2. deal with error
            var error:NSError?
            if !managedObjectContext.save(&error) {
                fatalCoreDataError(error)
            }
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return section.name
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditLocation" {
            let navigateController = segue.destinationViewController as UINavigationController
            let viewController = navigateController.topViewController as LocationDetailsViewController
            viewController.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPathForCell(sender as UITableViewCell) {
                viewController.locationToEdit = fetchedResultsController.objectAtIndexPath(indexPath) as? Location
            }
        }
    }
    
    //get core data
    private
    func performFetch() {
        var error:NSError?
        if !fetchedResultsController.performFetch(&error){
            fatalCoreDataError(error)
        }
    }

   
}

//these are standed code
extension LocationsViewController:NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        println("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            println("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRowsAtIndexPaths([newIndexPath!],withRowAnimation: .Fade)
        case .Delete:
            println("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!],withRowAnimation: .Fade)
        case .Update:
            println("*** NSFetchedResultsChangeUpdate (object)")
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as LocationCell
            let location = controller.objectAtIndexPath(indexPath!)as Location
            cell.configureForLocation(location)
        case .Move:
            println("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!],withRowAnimation: .Fade);
            tableView.insertRowsAtIndexPaths([newIndexPath!],withRowAnimation: .Fade)
        default:
            println("*** error NSFetchedResultsChangeUpdate (object)")
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
            switch type {
            case .Insert:
                println("*** NSFetchedResultsChangeInsert (section)")
                tableView.insertSections(NSIndexSet(index: sectionIndex),withRowAnimation: .Fade)
            case .Delete:
                println("*** NSFetchedResultsChangeDelete (section)")
                tableView.deleteSections(NSIndexSet(index: sectionIndex),withRowAnimation: .Fade)
                println("*** NSFetchedResultsChangeUpdate (section)")
            case .Move:
                println("*** NSFetchedResultsChangeMove (section)")
            default:
                println("*** error default operation")
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        println("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
    
}