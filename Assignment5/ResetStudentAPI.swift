//
//  ResetStudentAPI.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/14/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//

import Foundation

enum ResetStudentError: Error {
    case invalidJSONData
}

struct ResetStudentAPI {
    private static let baseURLString = "https://bismarck.sdsu.edu/registration/resetstudent"
    
    /*
     creates a URL to send to the server
     */
    static func resetStudentURL(parameters: [String:String]?) -> URL {
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
     creates a Reset instance from the json data
     */
    private static func reset(fromJSON json: [String : Any]) -> Reset? {
        guard
            let status = json.values.first as? String else {
                
                // Don't have enough information to construct a reset
                return nil
        }
        return Reset(status: status)
    }
    
    /*
     reconstruct the JSON data and append it to a resets array
     */
    static func resets(fromJSON data: Data) -> ResetStudentResult {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard
                let resetsDict = jsonObject as? [AnyHashable:Any] else {
                    
                    // The JSON structure doesn't match our expectations
                    return .failure(ResetStudentError.invalidJSONData)
            }
            
            var finalResets = [Reset]()
            if let reset = reset(fromJSON: resetsDict as! [String:Any]) {
                finalResets.append(reset)
            }
            
            if finalResets.isEmpty && !resetsDict.isEmpty {
                // We weren't able to parse any of the subjects
                return .failure(ResetStudentError.invalidJSONData)
            }
            
            return .success(finalResets)
        } catch let error {
            return .failure(error)
        }
    }
}
