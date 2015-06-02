//
//  StudentInfo.swift
//  OnTheMap
//
//  Created by Gerard Heng on 23/5/15.
//  Copyright (c) 2015 gLabs. All rights reserved.
//

import UIKit

struct StudentInfo {
    
    var createdAt: String?
    var firstName: String?
    var lastName: String?
    var latitude: Double?
    var longitude: Double?
    var mapString: String?
    var mediaURL: String?
    var objectId: String?
    var uniqueKey: String?
    var updatedAt: String?
    
    init(dictionary: [String: AnyObject]) {
        
        createdAt = dictionary["createdAt"] as? String
        firstName = dictionary["firstName"] as? String
        lastName = dictionary["lastName"] as? String
        latitude = dictionary["latitude"] as? Double
        longitude = dictionary["longitude"] as? Double
        mapString = dictionary["mapString"] as? String
        mediaURL = dictionary["mediaURL"] as? String
        objectId = dictionary["objectId"] as? String
        uniqueKey = dictionary["uniqueKey"] as? String
        
        updatedAt = dictionary["updatedAt"] as? String
        
    }
    
    static func studentsInfoResults(results: [[String : AnyObject]]) -> [StudentInfo] {
        
        var students = [StudentInfo]()
        
        for result in results {
            students.append(StudentInfo(dictionary: result))
        }
        return students
    }
    
}
