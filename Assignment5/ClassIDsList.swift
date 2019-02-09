//
//  ClassIDsList.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/14/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//

import Foundation

enum ClassIDsResult {
    case success([ClassID])
    case failure(Error)
}

class ClassIDsList {
    
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
    private func processClassIDsRequest(data: Data?, error: Error?) -> ClassIDsResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return ClassIDsListAPI.courses(fromJSON: jsonData)
    }
    
    /*
     GET method
     returns a JSON array of ints of the ids of the classes that are in the given subject and meet the given criteria
     */
    func fetchClassIDs(parameters: [String:String]?, completion: @escaping (ClassIDsResult) -> Void) {
        let url = ClassIDsListAPI.classIDsListURL(parameters: parameters)
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processClassIDsRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }
}
