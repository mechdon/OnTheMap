//
//  Client.swift
//  OnTheMap
//
//  Created by Gerard Heng on 29/5/15.
//  Copyright (c) 2015 gLabs. All rights reserved.
//

import Foundation
import UIKit

class Client : NSObject {
    
    /* Shared Session */
    var session : NSURLSession
    
    /* Authentication state */
    var sessionID: AnyObject?  = nil
    var userID: AnyObject? = nil
    var uniqueKey: String = ""
    
    override init() {
     session = NSURLSession.sharedSession()
        super.init()
    }
    
    // Authentication with Udacity server by posting a session and getting the sessionID
    func udacityLogin(username: String, password: String, completionHandler:(success: Bool, error: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 2.0)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, error: "Unable to create a session with the Udacity Server")
                return
            }
            
            Client.parseJSONWithCompletionHandler(data, completionHandler: { (result, error) in
                
                if error != nil {
                    completionHandler(success: false, error: "JSON Parsing Error")
                    return
                } else {
                    if var logerror: NSString = result["error"] as? NSString {
                        var error = logerror as String
                        completionHandler(success: false, error: error)
                } else{
                        if let sessionData = result["account"] as? NSDictionary {
                            self.sessionID = sessionData["key"]
                            self.uniqueKey = self.sessionID as! String
                            NSUserDefaults.standardUserDefaults().setObject(self.uniqueKey, forKey: "uniqueKey")
                            completionHandler(success: true, error: nil)
                    }
                }
                }
            })
            self.getUserData()
        }
        task.resume()
    }
    
    // Retrieve User's Personal Data using the sessionID
    func getUserData() {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(self.uniqueKey)")!)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
            return
            }
            
            Client.parseJSONWithCompletionHandler(data, completionHandler: { (result, error) in
                if error != nil {
                    return
                } else {
                    if let userData = result["user"] as? NSDictionary {
                        var firstName = userData["first_name"] as! String
                        var lastName = userData["last_name"] as! String
                        NSUserDefaults.standardUserDefaults().setObject(firstName, forKey: "firstName")
                        NSUserDefaults.standardUserDefaults().setObject(lastName, forKey: "lastName")
                    }
                }
            })
        }
        task.resume()
    }
    
    // JSON Parsing with completionHandler
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void)
        {
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))

            var parsingError: NSError? = nil
            
            let jsonDict = NSJSONSerialization.JSONObjectWithData(newData, options: nil, error: &parsingError) as! NSDictionary
    
            if let error = parsingError {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: jsonDict, error: nil)
            }
        }

   // Get Locations of the Users
   func getStudentLocations(completionHandler: (result: [[String : AnyObject]], error: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                return
            }
            let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil ) as! [String : AnyObject]
            if let results = parsedResult["results"] as? [[String : AnyObject]] {
                completionHandler(result: results, error: nil)
            }
        }
        task.resume()
    }
    
    // Post User Location
    func postUserLocation(uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: String, lat: String, lon: String, completionHandler:(success: Bool, error: String!) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(lat), \"longitude\": \(lon)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, error: "Unable to post user location")
            } else {
                completionHandler(success: true, error: nil)
            }
        }
        task.resume()
    }
    
    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> Client {
        
        struct Singleton {
            static var sharedInstance = Client()
        }
        
        return Singleton.sharedInstance
    }

    
    
    
}
