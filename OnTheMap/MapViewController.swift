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
        IndicatorView.shared.showActivityIndicator(view)
        let rightRefreshButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refresh:")
        let rightLocateButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "location"), style: UIBarButtonItemStyle.Plain, target: self, action: "locate:")
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
            
            let latitude:CLLocationDegrees = lat
            let longitude:CLLocationDegrees = lon
            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = "\(firstName) \(lastName)"
            annotation.subtitle = mediaURL
            annotations.append(annotation)
        }
        
        map.addAnnotations(annotations)
        dispatch_async(dispatch_get_main_queue()) {
            self.map.showAnnotations(annotations, animated: true)
            IndicatorView.shared.hideActivityIndicator()
        }

    }
    
    //# MARK: - MapView functions
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Set Callout
       
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = self.map.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: UIButtonType.InfoLight) as UIView
            }
            return view
        }
   
    
    // Attempt to launch URL when callout is tapped
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
       /* if let url = view.annotation.subtitle {
            UIApplication.sharedApplication().openURL(NSURL(string: url!)!)
        } else {
            showAlertMsg("Error", errorMsg: "Could not find a URL to launch")
        }*/
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
