//
//  Student.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/21/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//

import Foundation

class Student {
    let firstName: String
    let lastName: String
    let redid: String
    let password: String
    let email: String
    
    init(firstName: String, lastName: String, redid: String, password: String, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.redid = redid
        self.password = password
        self.email = email
    }
}
