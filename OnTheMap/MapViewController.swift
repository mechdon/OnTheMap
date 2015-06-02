//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Gerard Heng on 21/5/15.
//  Copyright (c) 2015 gLabs. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // Outlet for MapView
    @IBOutlet weak var map: MKMapView!
    
    // Activity Indicator Declaration
    var activityIndicator: UIActivityIndicatorView!
    
    // Declare variables
    var students: [StudentInfo] = [StudentInfo]()
    var firstName = ""
    var lastName = ""
    var lat: Double = 0.0
    var lon: Double = 0.0
    var mediaURL = ""
    let loginManager = FBSDKLoginManager()
    
    // Progammatically set Navigation Bar Button Items
    override func viewDidLoad() {
        showActivityIndicator()
        var rightRefreshButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refresh:")
        var rightLocateButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "location"), style: UIBarButtonItemStyle.Plain, target: self, action: "locate:")
        self.navigationItem.setRightBarButtonItems([rightRefreshButtonItem, rightLocateButtonItem], animated: true)
        
        // Get student locations and add annotations to map
        Client.sharedInstance().getStudentLocations() {(students, error) in
            if error != nil {
                self.showAlertMsg("Download Error", errorMsg: error!)
            } else {
                self.students = StudentInfo.studentsInfoResults(students)
                self.addAnnotationsToMap()
            }
        }
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
    
    // Function for adding annotations to Map
    func addAnnotationsToMap() {
        
        var annotations = [MKAnnotation]()
    
        for var i = 0; i < students.count; i++ {
            
            if students[i].latitude != nil {
                lat = students[i].latitude!
            }
            if students[i].longitude != nil {
                lon = students[i].longitude!
            }
            if students[i].firstName != nil {
                firstName = students[i].firstName!
            }
            if students[i].lastName != nil {
                lastName = students[i].lastName!
            }
            if students[i].mediaURL != nil {
                mediaURL = students[i].mediaURL!
            }
            
            var latitude:CLLocationDegrees = lat
            var longitude:CLLocationDegrees = lon
            var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            var annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = "\(firstName) \(lastName)"
            annotation.subtitle = mediaURL
            annotations.append(annotation)
        }
        
        map.addAnnotations(annotations)
        dispatch_async(dispatch_get_main_queue()) {
            self.map.showAnnotations(annotations, animated: true)
            self.hideActivityIndicator()
        }

    }
    
    //# MARK: - MapView functions
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        // Set Callout
        if let annotation = annotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = self.map.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.InfoLight) as! UIView
            }
            return view
        }
        return nil
    }
    
    // Attempt to launch URL when callout is tapped
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if let url = view.annotation.subtitle {
            UIApplication.sharedApplication().openURL(NSURL(string: url!)!)
        } else {
            showAlertMsg("Error", errorMsg: "Could not find a URL to launch")
        }
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
    
    //# MARK: - Navigation Bar Button Items
    
    // Refresh Map
    func refresh(sender: UIBarButtonItem){
        Client.sharedInstance().getStudentLocations() {(students, error) in
            if error != nil {
                self.showAlertMsg("Parsing Error", errorMsg: error!)
            } else {
                self.students = StudentInfo.studentsInfoResults(students)
                self.addAnnotationsToMap()
            }
        }
    }
    
    // Post User Location
    func locate(sender: UIBarButtonItem) {
        let infoPostVC = self.storyboard?.instantiateViewControllerWithIdentifier("InfoPostViewController") as! InfoPostViewController
        self.navigationController?.pushViewController(infoPostVC, animated: true)    }
    
    // Logout Button Pressed
    @IBAction func loggedoutButtonPressed(sender: AnyObject) {
        loginManager.logOut()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
