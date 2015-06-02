//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Gerard Heng on 22/5/15.
//  Copyright (c) 2015 gLabs. All rights reserved.
//

import UIKit

class TableViewController:UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Activity Indicator Declaration
    var activityIndicator: UIActivityIndicatorView!
    
    // Declare variables
    var studentNamesTableView: UITableView!
    var students: [StudentInfo] = [StudentInfo]()
    var firstName = ""
    var lastName = ""
    var mediaURL = ""
    let loginManager = FBSDKLoginManager()
    
    // Progammatically set Navigation Bar Button Items
    override func viewDidLoad() {
        showActivityIndicator()
        var rightRefreshButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refresh:")
        var rightLocateButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "location"), style: UIBarButtonItemStyle.Plain, target: self, action: "locate:")
        self.navigationItem.setRightBarButtonItems([rightRefreshButtonItem, rightLocateButtonItem], animated: true)
        
        Client.sharedInstance().getStudentLocations() {(students, error) in
            if error != nil {
                self.showAlertMsg("Download Error", errorMsg: error!)
            } else {
                self.students = StudentInfo.studentsInfoResults(students)
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                    self.hideActivityIndicator()
                }
            }
        }
    }
    
    // Reload Student Names on Table
    override func viewWillAppear(animated: Bool) {
        self.studentNamesTableView = self.view.viewWithTag(1) as! UITableView
        self.studentNamesTableView.reloadData()
    }
    
    //# MARK: - Functions for showing and hiding activity indicator
    func showActivityIndicator(){
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.frame = CGRectMake((screenWidth/2 - 50), (screenHeight/2 - 50), 100, 100);
        activityIndicator.startAnimating()
        self.view.addSubview( activityIndicator )
    }
    
    func hideActivityIndicator(){
        activityIndicator.stopAnimating()
    }

    
    // Function to show Alert Message
    func showAlertMsg(errorTitle: String, errorMsg: String) {
        var title = errorTitle
        var errormsg = errorMsg
        
        NSOperationQueue.mainQueue().addOperationWithBlock{ var alert = UIAlertController(title: title, message: errormsg, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                self.dismissViewControllerAnimated(true, completion: nil)
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("customCell", forIndexPath: indexPath) as! UITableViewCell
        let student: StudentInfo = students[indexPath.row] as StudentInfo
        if student.firstName != nil {
            firstName = student.firstName!
        }
        
        if student.lastName != nil {
            lastName = student.lastName!
        }
        
        var studentname = firstName + " " + lastName
        var studentNameLabel: UILabel = cell.contentView.viewWithTag(101) as! UILabel
        studentNameLabel.text = studentname
        var cellImageView: UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
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
        Client.sharedInstance().getStudentLocations() {(students, error) in
            if error != nil {
                self.showAlertMsg("Parsing Error", errorMsg: error!)
            } else {
                self.students = StudentInfo.studentsInfoResults(students)
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
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
