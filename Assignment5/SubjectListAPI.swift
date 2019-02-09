//
//  SubjectListAPI.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/14/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//

import Foundation

enum SubjectError: Error {
    case invalidJSONData
}

struct SubjectListAPI {
    
    private static let baseURLString = "https://bismarck.sdsu.edu/registration/subjectlist"
    
    /*
     creates the parameters for the URL
     */
    static var subjectListParams: URL {
        return subjectListURL(parameters: [:])
    }
    
    /*
     creates a URL to send to the server
     */
    private static func subjectListURL(parameters: [String:String]?) -> URL {
        
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
     creates a Subject instance from the json data
     */
    private static func subject(fromJSON json: [String : Any]) -> Subject? {
        guard
            let title = json["title"] as? String,
            let id = json["id"] as? Int,
            let college = json["college"] as? String,
            let classes = json["classes"] as? Int else {
                
                // Don't have enough information to construct a subject
                return nil
        }
        
        return Subject(title: title, id: id, college: college, classes: classes)
    }
    
    /*
     reconstruct the JSON data and append it to a subjects array
     */
    static func subjects(fromJSON data: Data) -> SubjectsResult {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard
            let subjectsArray = jsonObject as? [[String:Any]] else {
                
                // The JSON structure doesn't match our expectations
                return .failure(SubjectError.invalidJSONData)
            }
            
            var finalSubjects = [Subject]()
            for subjectJSON in subjectsArray {
                if let subject = subject(fromJSON: subjectJSON) {
                    finalSubjects.append(subject)
                }
            }
            
            if finalSubjects.isEmpty && !subjectsArray.isEmpty {
                // We weren't able to parse any of the subjects
                return .failure(SubjectError.invalidJSONData)
            }
            
            return .success(finalSubjects)
        } catch let error {
            return .failure(error)
        }
    }
}
