//
//  ClassDetailsAPI.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/14/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//

import Foundation

enum ClassDetailsError: Error {
    case invalidJSONData
}

struct ClassDetailsAPI {
    private static let baseURLString = "https://bismarck.sdsu.edu/registration/classdetails"
    
    
    /*
     creates a URL to send to the server
     */
    static func classDetailsURL(parameters: [String:String]?) -> URL {
        var components = URLComponents(string: baseURLString)!
        var queryItems = [URLQueryItem]()
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        components.queryItems = queryItems
        
        return components.url!
    }
    
    /*
     creates a Details instance from the json data
     */
    private static func detail(fromJSON json: [String : Any]) -> Details? {
        guard
            let description = json["description"] as? String,
            let department = json["department"] as? String,
            let suffix = json["suffix"] as? String,
            let building = json["building"] as? String,
            let startTime = json["startTime"] as? String,
            let meetingType = json["meetingType"] as? String,
            let section = json["section"] as? String,
            let endTime = json["endTime"] as? String,
            let enrolled = json["enrolled"] as? Int,
            let days = json["days"] as? String,
            let prerequisite = json["prerequisite"] as? String,
            let title = json["title"] as? String,
            let id = json["id"] as? Int,
            let instructor = json["instructor"] as? String,
            let scheduleNum = json["schedule#"] as? String,
            let units = json["units"] as? String,
            let room = json["room"] as? String,
            let waitlist = json["waitlist"] as? Int,
            let seats = json["seats"] as? Int,
            let fullTitle = json["fullTitle"] as? String,
            let subject = json["subject"] as? String,
            let courseNum = json["course#"] as? String else {
                
                // Don't have enough information to construct a detail
                return nil
        }
        
        return Details(description: description, department: department, suffix: suffix, building: building, startTime: startTime, meetingType: meetingType, section: section, endTime: endTime, enrolled: enrolled, days: days, prerequisite: prerequisite, title: title, id: id, instructor: instructor, scheduleNum: scheduleNum, units: units, room: room, waitlist: waitlist, seats: seats, fullTitle: fullTitle, subject: subject, courseNum: courseNum)
    }
    
    /*
     reconstruct the JSON data and append it to a details array
     */
    static func details(fromJSON data: Data) -> ClassDetailsResult {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard
                let detailsDict = jsonObject as? [AnyHashable:Any] else {
                    // The JSON structure doesn't match our expectations
                    return .failure(ClassDetailsError.invalidJSONData)
            }
            
            var finalDetails = [Details]()
            if let detail = detail(fromJSON: detailsDict as! [String : Any]) {
                finalDetails.append(detail)
            }
            
            if finalDetails.isEmpty && !detailsDict.isEmpty {
                // We weren't able to parse any of the Details
                return .failure(ClassDetailsError.invalidJSONData)
            }
            
            return .success(finalDetails)
        } catch let error {
            return .failure(error)
        }
    }
}
