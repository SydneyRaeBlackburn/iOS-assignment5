//
//  Details.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/14/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//

import Foundation

class Details {
    
    let description: String
    let department: String
    let suffix: String?
    let building: String
    let startTime: String
    let meetingType: String
    let section: String
    let endTime: String
    let enrolled: Int
    let days: String
    let prerequisite: String
    let title: String
    let id: Int
    let instructor: String
    let scheduleNum: String
    let units: String
    let room: String
    let waitlist: Int
    let seats: Int
    let fullTitle: String
    let subject: String
    let courseNum: String
    
    init(description: String, department: String, suffix: String?, building: String, startTime: String, meetingType: String, section: String, endTime: String, enrolled: Int, days: String, prerequisite: String, title: String, id: Int, instructor: String, scheduleNum: String, units: String, room: String, waitlist: Int, seats: Int, fullTitle: String, subject: String, courseNum: String) {
        
        self.description = description
        self.department = department
        self.suffix = suffix
        self.building = building
        self.startTime = startTime
        self.meetingType = meetingType
        self.section = section
        self.endTime = endTime
        self.enrolled = enrolled
        self.days = days
        self.prerequisite = prerequisite
        self.title = title
        self.id = id
        self.instructor = instructor
        self.scheduleNum = scheduleNum
        self.units = units
        self.room = room
        self.waitlist = waitlist
        self.seats = seats
        self.fullTitle = fullTitle
        self.subject = subject
        self.courseNum = courseNum
    }
}
