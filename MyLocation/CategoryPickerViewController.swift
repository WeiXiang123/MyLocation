//
//  CategoryPickerViewController.swift
//  MyLocation
//
//  Created by WeiXiang on 15/1/6.
//  Copyright (c) 2015年 WeiXiang. All rights reserved.
//

import UIKit

protocol CategoryPickerDelegate: class{
    func categoryPickerDidPickCategory(controller:CategoryPickerViewController)
}

class CategoryPickerViewController: UITableViewController {

    var selectedCategoryName = ""
    var selectedIndexPath = NSIndexPath()
    var delegate:CategoryPickerDelegate?
    
    let categories = [
        "No Category",
        "Apple Store",
        "Bar",
        "Bookstore",
        "Club",
        "Grocery Store",
        "Historic Building",
        "House",
        "Icecream Vendor",
        "Landmark",
        "Park"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return categories.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        
        if categoryName == selectedCategoryName {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            selectedIndexPath = indexPath
        }else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            if indexPath.row != selectedIndexPath.row {
                if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                }
                if let cell = tableView.cellForRowAtIndexPath(selectedIndexPath) {
                    cell.accessoryType = UITableViewCellAccessoryType.None
                }
                selectedIndexPath = indexPath
                selectedCategoryName = categories[indexPath.row]
                delegate!.categoryPickerDidPickCategory(self)
            }

    }

    

}
