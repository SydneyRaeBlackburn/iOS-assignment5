//
//  Subject.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/14/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//

import Foundation

class Subject {
    
    let title: String
    let id: Int
    let college: String
    let classes: Int
    
    init(title: String, id: Int, college: String, classes: Int) {
        self.title = title
        self.id = id
        self.college = college
        self.classes = classes
    }
}
