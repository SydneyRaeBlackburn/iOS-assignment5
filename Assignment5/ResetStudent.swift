//
//  ResetStudent.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/14/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//

import Foundation

enum ResetStudentResult {
    case success([Reset])
    case failure(Error)
}

class ResetStudent {
    
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
    private func processResetStudentRequest(data: Data?, error: Error?) -> ResetStudentResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return ResetStudentAPI.resets(fromJSON: jsonData)
    }
    
    /*
     GET method
     returns a JSON object with one key: ok or error
     */
    func fetchResetStudent(parameters: [String:String]?, completion: @escaping (ResetStudentResult) -> Void) {
        let url = ResetStudentAPI.resetStudentURL(parameters: parameters)
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processResetStudentRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }
}
