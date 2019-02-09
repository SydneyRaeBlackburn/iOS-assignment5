//
//  CoursesFoundViewController.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/17/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//

import UIKit

class CoursesFoundViewController: UITableViewController {
    
    // MARK: vars
    
    // The registered and waitlisted courses in an array, and their details, and the students info
    // These variables will be passed around the view controllers
    var student: Student?
    var studentClasses: [Int]?
    var waitlist: [Int]?
    var studentClassDetails: [Details]?
    var waitlistDetails: [Details]?
    
    // create empty arrays to hold the courses and details found
    var courseIds: [ClassID]?
    var details: [Details]?
    
    // MARK: instance methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set table requirements and reload
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 65
        
        self.tableView.reloadData()
        
    }
    
    // MARK: tableview functions
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (details?.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get  new or recycled cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as! CourseCell
        
        let course = details![indexPath.row]
        
        // update cell information
        cell.subjectLabel.text = "\(course.subject)"
        cell.courseNumLabel.text = "\(course.courseNum)"
        cell.timeLabel.text = "\(course.startTime) - \(course.endTime)"
        cell.daysLabel.text = "\(course.days)"
        
        return cell
    }
    
    // MARK: segue functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showDetails":
            // Figure out which row was tapped
            if let row = tableView.indexPathForSelectedRow?.row {
                // Get info associated with row and pass it along
                let classDetails = details![row]
                let classDetailViewController = segue.destination as! ClassDetailViewController
                
                // pass necessary details to ClassDetailViewController
                classDetailViewController.details = classDetails
                classDetailViewController.student = student
                classDetailViewController.studentClasses = self.studentClasses
                classDetailViewController.waitlist = self.waitlist
                classDetailViewController.classDetails = self.studentClassDetails
                classDetailViewController.waitlistDetails = self.waitlistDetails
            }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
}
