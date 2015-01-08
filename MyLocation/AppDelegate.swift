//
//  AppDelegate.swift
//  MyLocation
//
//  Created by WeiXiang on 15/1/5.
//  Copyright (c) 2015年 WeiXiang. All rights reserved.
//

import UIKit
import CoreData

let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"

func fatalCoreDataError(error: NSError?){
    if let error = error {
        println("*** Fatal error\(error), \(error.userInfo)")
    }
    NSNotificationCenter.defaultCenter().postNotificationName(MyManagedObjectContextSaveDidFailNotification, object: error)
}




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //core data init (common format) and connect it to an SQLite data store
    lazy var managedObjectContext: NSManagedObjectContext = {
        //folder named “DataModel.momd”
        if let modelURL = NSBundle.mainBundle().URLForResource("DataModel",withExtension: "momd") {
            // model :the data model during runtime
            if let model = NSManagedObjectModel(contentsOfURL: modelURL) as NSManagedObjectModel! {
                //is in charge of the SQLite database.
                let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
                
                //The app’s data is stored in an SQLite database inside the app’s Documents folder. Here create an NSURL object pointing at the DataStore.sqlite file
                let urls = NSFileManager.defaultManager().URLsForDirectory( .DocumentDirectory, inDomains: .UserDomainMask)
                let documentsDirectory = urls[0] as NSURL
                let storeURL = documentsDirectory.URLByAppendingPathComponent("DataStore.sqlite")
                println(storeURL)
                
                //Add the SQLite database to the store coordinator
                var error: NSError?
                if let store = coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) {
                    let context = NSManagedObjectContext();
                    context.persistentStoreCoordinator = coordinator;
                    return context  //success!
                } else {
                    println("Error adding persistent store at \(storeURL): \(error!)")
                }
            
            } else {
                println("Error initializing model from: \(modelURL)")
            }
        } else {
            println("Could not find data model in app bundle")
        }
        abort()
    }()
        
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //pass the coredata to next
        let rootController = window!.rootViewController as UITabBarController
        if let viewControllers = rootController.viewControllers {
        
            let viewController = viewControllers[0] as CurLocationViewController
            viewController.managedObjectContext = managedObjectContext
        }
                        
        listenFatalCoreDataNotification()
                        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    private
    func listenFatalCoreDataNotification() {
        //1. register observer
        NSNotificationCenter.defaultCenter().addObserverForName(MyManagedObjectContextSaveDidFailNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
        //2. show alert
        notification in
        
        let alert = UIAlertController(title: "Internal Error", message: "There was a fatal error in the app and it cannot continue.\n\n" + "Press OK to terminate the app. Sorry for the inconvenience.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
        _ in
            let exception = NSException(name: NSInternalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil)
            exception.raise()
        }
        alert.addAction(action)
        
        self.viewControllerForShowAlert().presentViewController(alert, animated: true, completion: nil)
        })
        
    }
    
    private
    func viewControllerForShowAlert()->UIViewController {
        //1. cur view is root view
        //2. other view
        let rootViewController = self.window!.rootViewController!
        if let presentView = rootViewController.presentedViewController {
            return presentView
        }else{
            return rootViewController
        }
            
    }

}

