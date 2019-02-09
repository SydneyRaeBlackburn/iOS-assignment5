//
//  ClassDetails.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/14/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//

import Foundation

enum ClassDetailsResult {
    case success([Details])
    case failure(Error)
}

class ClassDetails {
    
    /*
     create a URLSession
     */
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    /*
     process request
     */
    private func processClassDetailsRequest(data: Data?, error: Error?) -> ClassDetailsResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return ClassDetailsAPI.details(fromJSON: jsonData)
    }
    
    /*
     GET method
     returns a JSON object of 22 key-value pairs
     */
    func fetchClassDetails(parameters: [String:String]?, completion: @escaping (ClassDetailsResult) -> Void) {
        let url = ClassDetailsAPI.classDetailsURL(parameters: parameters)
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processClassDetailsRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }
}
