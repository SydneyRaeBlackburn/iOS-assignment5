//
//  SubjectList.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/14/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//

import Foundation

enum SubjectsResult {
    case success([Subject])
    case failure(Error)
}

class SubjectList {
    
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
    private func processSubjectsRequest(data: Data?, error: Error?) -> SubjectsResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return SubjectListAPI.subjects(fromJSON: jsonData)
    }
    
    /*
     GET method
     returns a JSON object of 4 key-value pairs: "title", "id", "classes", "colleges"
     */
    func fetchSubjectList(completion: @escaping (SubjectsResult) -> Void) {
        let url = SubjectListAPI.subjectListParams
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            
            let result = self.processSubjectsRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }
}
