//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Gerard Heng on 22/5/15.
//  Copyright (c) 2015 gLabs. All rights reserved.
//

import UIKit

class TableViewController:UITableViewController {
    
    // Declare variables
    var studentNamesTableView: UITableView!
    var students: [StudentInfo] = [StudentInfo]()
    var firstName = ""
    var lastName = ""
    var mediaURL = ""
    let loginManager = FBSDKLoginManager()
    
    // Progammatically set Navigation Bar Button Items
    override func viewDidLoad() {
        IndicatorView.shared.showActivityIndicator(view)
        let rightRefreshButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refresh:")
        let rightLocateButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "location"), style: UIBarButtonItemStyle.Plain, target: self, action: "locate:")
        self.navigationItem.setRightBarButtonItems([rightRefreshButtonItem, rightLocateButtonItem], animated: true)
        
        Client.sharedInstance().getStudentLocations() {(students, error) in
            if error != nil {
                self.showAlertMsg("Download Error", errorMsg: error!)
                IndicatorView.shared.hideActivityIndicator()
            } else {
                self.students = StudentInfo.studentsInfoResults(students)
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                    IndicatorView.shared.hideActivityIndicator()
                }
            }
        }
    }
    
    // Reload Student Names on Table
    override func viewWillAppear(animated: Bool) {
        self.studentNamesTableView = self.view.viewWithTag(1) as! UITableView
        self.studentNamesTableView.reloadData()
    }
        
    // Function to show Alert Message
    func showAlertMsg(errorTitle: String, errorMsg: String) {
        let title = errorTitle
        let errormsg = errorMsg
        
        NSOperationQueue.mainQueue().addOperationWithBlock{ let alert = UIAlertController(title: title, message: errormsg, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //# MARK - TableView Methods
    
    
    // Return number of students
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return students.count
    }
    
    // Populate rows with each student's firstname and lastname
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("customCell", forIndexPath: indexPath) 
        let student: StudentInfo = students[indexPath.row] as StudentInfo
        if student.firstName != nil {
            firstName = student.firstName!
        }
        
        if student.lastName != nil {
            lastName = student.lastName!
        }
        
        let studentname = firstName + " " + lastName
        let studentNameLabel: UILabel = cell.contentView.viewWithTag(101) as! UILabel
        studentNameLabel.text = studentname
        let cellImageView: UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        cellImageView.image = UIImage(named: "location")
        return cell
    }
    
    // Launch corresponding URL for selected row
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student: StudentInfo = students[indexPath.row] as StudentInfo
        if student.mediaURL != nil {
            mediaURL = student.mediaURL!
        }
        UIApplication.sharedApplication().openURL(NSURL(string: mediaURL)!)
    }
    
    
    //# MARK: - Navigation Bar Button Items
    
    
    // Refresh Table
    func refresh(sender: UIBarButtonItem){
        IndicatorView.shared.showActivityIndicator(view)
        Client.sharedInstance().getStudentLocations() {(students, error) in
            if error != nil {
                self.showAlertMsg("Parsing Error", errorMsg: error!)
            } else {
                self.students = StudentInfo.studentsInfoResults(students)
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                    IndicatorView.shared.hideActivityIndicator()
                }
            }
        }
    }
    
    // Post User Location
    func locate(sender: UIBarButtonItem) {
        let infoPostVC = self.storyboard?.instantiateViewControllerWithIdentifier("InfoPostViewController") as! InfoPostViewController
        self.navigationController?.pushViewController(infoPostVC, animated: true)
    }
    
    // Logout Button Pressed
    @IBAction func logoutButton(sender: AnyObject) {
        loginManager.logOut()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
