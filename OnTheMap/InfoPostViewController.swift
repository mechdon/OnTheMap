//
//  InfoPostViewController.swift
//  OnTheMap
//
//  Created by Gerard Heng on 26/5/15.
//  Copyright (c) 2015 gLabs. All rights reserved.
//

import UIKit
import MapKit

class InfoPostViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    // View component outlets
    @IBOutlet weak var urlInfoPostTF: UITextField!
    @IBOutlet weak var mapviewInfoPost: MKMapView!
    @IBOutlet weak var infoSubmitButton: UIButton!
    @IBOutlet weak var promptInfoPost: UITextView!
    @IBOutlet weak var infoPostTF: UITextField!
    @IBOutlet weak var infoFindButton: UIButton!
    
    // Declare varables
    var uniqueKey: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var mapString: String = ""
    var mediaURL: String = ""
    var lat: String = ""
    var lon: String = ""
    var location: CLLocation!
    var region: MKCoordinateRegion!
    var latitude: AnyObject?
    var longitude: AnyObject?
    var errorMsg: String = ""
    
    // Set right bar button item and initialte view
    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancel")
        urlInfoPostTF.hidden = true
        mapviewInfoPost.hidden = true
        infoSubmitButton.hidden = true
        promptInfoPost.hidden = false
        infoPostTF.hidden = false
        infoFindButton.hidden = false
        self.urlInfoPostTF.delegate = self
        self.infoPostTF.delegate = self
    }
    
    // Function to show Alert Message
    func showAlertMsg(errorTitle: String, errorMsg: String) {
        var title = errorTitle
        var errormsg = errorMsg
        
        NSOperationQueue.mainQueue().addOperationWithBlock{ var alert = UIAlertController(title: title, message: errormsg, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                // No further action apart from dismissing this alert
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Find location button pressed
    @IBAction func findonMapButton(sender: AnyObject) {
        mapString = infoPostTF.text
        
        // Prompt user to enter location if field is empty
        if infoPostTF.text == "" {
            showAlertMsg("Location Empty", errorMsg: "Please enter your location")
            return
        } else {
            // Forward geocode the mapString
            
            IndicatorView.shared.showActivityIndicator(view)
            var geocoder = CLGeocoder()
            geocoder.geocodeAddressString(mapString, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                if error != nil {
                    var errorMsg = error.localizedDescription
                    
                    // Show Error Alert if invalid location is entered
                    self.showAlertMsg("GeoCoding Error", errorMsg: errorMsg)
                    IndicatorView.shared.hideActivityIndicator()
                    return
                } else {
                    // Switch view
                    self.urlInfoPostTF.hidden = false
                    self.mapviewInfoPost.hidden = false
                    self.infoSubmitButton.hidden = false
                    self.promptInfoPost.hidden = true
                    self.infoPostTF.hidden = true
                    self.infoFindButton.hidden = true
                }
                
                if let placemark = placemarks[0] as? CLPlacemark {
                    self.mapviewInfoPost.addAnnotation(MKPlacemark(placemark: placemark))
                    let coordinate = placemark.location.coordinate
                    self.latitude = placemark.location.coordinate.latitude
                    self.longitude = placemark.location.coordinate.longitude
                    let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                    self.region = MKCoordinateRegion(center: coordinate, span: span)
                    self.mapviewInfoPost.setRegion(self.region!, animated: true)
                    IndicatorView.shared.hideActivityIndicator()
                }
            })
        }
    }
    
    // Textfield resigns first responder when return key is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Submit button pressed
    @IBAction func submitButton(sender: AnyObject) {
        
        mediaURL = urlInfoPostTF.text
        
        if mediaURL == "" {
            showAlertMsg("MediaURL Empty", errorMsg: "Please enter your URL")
            return
        } else {
            uniqueKey = NSUserDefaults.standardUserDefaults().objectForKey("uniqueKey")! as! String
            firstName = NSUserDefaults.standardUserDefaults().objectForKey("firstName")! as! String
            lastName = NSUserDefaults.standardUserDefaults().objectForKey("lastName")! as! String
            
            lat = self.latitude!.stringValue
            lon = self.longitude!.stringValue
            
            IndicatorView.shared.showActivityIndicator(view)
            
            Client.sharedInstance().postUserLocation(uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, lat: lat, lon: lon, completionHandler: { (success, error) in
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.cancel()
                        IndicatorView.shared.hideActivityIndicator()
                    }
                } else {
                    self.showAlertMsg("Post Error", errorMsg: error)
                }
            })
        }
    }
    
    // Cancel button pressed
    func cancel() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    
}