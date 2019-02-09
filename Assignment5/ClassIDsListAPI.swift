//
//  ClassIDsListAPI.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/14/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//

import Foundation

enum ClassIDError: Error {
    case invalidJSONData
}

struct ClassIDsListAPI {
    
    private static let baseURLString = "https://bismarck.sdsu.edu/registration/classidslist"
    
    /*
     creates a URL to send to the server
     */
    static func classIDsListURL(parameters: [String:String]?) -> URL {
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
     creates a Course instance from the json data
     */
    private static func course(fromJSON json: Int) -> ClassID? {
        return ClassID(id: json)
    }
    
    /*
     reconstruct the JSON data and append it to a courses array
     */
    static func courses(fromJSON data: Data) -> ClassIDsResult {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard
                let coursesArray = jsonObject as? [Int] else {
                    
                    // The JSON structure doesn't match our expectations
                    return .failure(ClassIDError.invalidJSONData)
            }
            
            var finalCourses = [ClassID]()
            for courseJSON in coursesArray {
                if let course = course(fromJSON: courseJSON) {
                    finalCourses.append(course)
                }
            }
            
            if finalCourses.isEmpty && !coursesArray.isEmpty {
                // We weren't able to parse any of the courses
                return .failure(ClassIDError.invalidJSONData)
            }
            
            return .success(finalCourses)
        } catch let error {
            return .failure(error)
        }
    }
}
