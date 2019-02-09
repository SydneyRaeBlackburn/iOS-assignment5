//
//  MyClassesViewController.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/16/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//

import UIKit

class MyClassesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: vars
    
    // Used for the webservice functions
    var subjects = SubjectList()
    var reset = ResetStudent()
    
    // The registered and waitlisted courses in an array, and their details, and the students info
    // These variables will be passed around the view controllers
    var student: Student?
    var studentClasses: [Int]?
    var waitlist: [Int]?
    var classDetails: [Details]?
    var waitlistDetails: [Details]?
    
    // data storage for calls to webservice functions
    var titles = [String]()
    var ids = [Int]()
    var colleges = [String]()
    var classes = [Int]()
    
    // MARK: outlets
    
    @IBOutlet weak var registeredClassesTableView: UITableView!
    @IBOutlet weak var waitlistedClassesTableView: UITableView!
    
    // MARK: actions
    
    @IBAction func resetButton(_ sender: UIButton) {
        
        //Add an alert before reseting all the student courses
        
        let title = "Reset Courses"
        let message = "Are you sure you want to unregister and unwaitlist from all courses?"
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        
        let resetAction = UIAlertAction(title: "Reset", style: .destructive, handler: { (action) -> Void in
            
            // remove students classes from registered and waitlisted courses
            self.reset.fetchResetStudent(parameters: ["redid": self.student!.redid, "password": self.student!.password]) {
                (resetResult) -> Void in
                
                switch resetResult {
                    
                // if successful, reset registered and waitlisted arrays, and both detail arrays
                // then reload the view controller
                case let .success(resets):
                    for reset in resets {
                        if reset.status == "Student reset" {
                            OperationQueue.main.addOperation {
                                self.studentClasses = []
                                self.waitlist = []
                                self.classDetails = []
                                self.waitlistDetails = []
                                self.viewDidLoad()
                            }
                        } else {
                            print("Error: \(reset.status)")
                        }
                    }
                case let .failure(error):
                    print("Error fetching resets: \(error)")
                }
            }
        })
        
        ac.addAction(resetAction)
        
        present(ac, animated: true, completion: nil)
    }
    
    // MARK: instance methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // instantiate tables
        if registeredClassesTableView != nil {
            registeredClassesTableView!.delegate = self
            registeredClassesTableView!.dataSource = self
        }
        registeredClassesTableView.rowHeight = UITableView.automaticDimension
        registeredClassesTableView.estimatedRowHeight = 65
        
        if waitlistedClassesTableView != nil {
            waitlistedClassesTableView!.delegate = self
            waitlistedClassesTableView!.dataSource = self
        }
        waitlistedClassesTableView.rowHeight = UITableView.automaticDimension
        waitlistedClassesTableView.estimatedRowHeight = 65
        
        // get a JSON object of subjects and store in stoarge arrays
        subjects.fetchSubjectList{
            (subjectsResult) -> Void in
            
            switch subjectsResult {
                
            // if successful, store data in arrays
            case let .success(subjects):
                print("Successfully found \(subjects.count) subjects.")
                for course in subjects {
                    self.titles.append(course.title)
                    self.ids.append(course.id)
                    self.colleges.append(course.college)
                    self.classes.append(course.classes)
                }
            case let .failure(error):
                print("Error fetching subjects: \(error)")
            }
        }
        
        // reload table
        self.registeredClassesTableView.reloadData()
        self.waitlistedClassesTableView.reloadData()
    }
    
    // MARKL table functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == registeredClassesTableView {
            return classDetails!.count
        } else if tableView == waitlistedClassesTableView {
            return waitlistDetails!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get  new or recycled cell
        if tableView == registeredClassesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegisteredCourseCell", for: indexPath) as! RegisteredCourseCell
            
            let course = classDetails![indexPath.row]
            
            // update cell information
            cell.subjectLabel.text = "\(course.subject)"
            cell.courseNumLabel.text = "\(course.courseNum)"
            cell.timeLabel.text = "\(course.startTime) - \(course.endTime)"
            cell.daysLabel.text = "\(course.days)"
            
            return cell
            
        } else if tableView == waitlistedClassesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WaitlistedCourseCell", for: indexPath) as! WaitlistedCourseCell
            
            let course = waitlistDetails![indexPath.row]
            
            // update cell information
            cell.subjectLabel.text = "\(course.subject)"
            cell.courseNumLabel.text = "\(course.courseNum)"
            cell.timeLabel.text = "\(course.startTime) - \(course.endTime)"
            cell.daysLabel.text = "\(course.days)"
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    // MARK: segue functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "findClasses"?:
            if segue.destination is FindCoursesViewController {
                
                // pass necessary details to FindCoursesViewController
                let findCoursesViewController = segue.destination as? FindCoursesViewController
                findCoursesViewController?.titles = self.titles
                findCoursesViewController?.ids = self.ids
                findCoursesViewController?.colleges = self.colleges
                findCoursesViewController?.classes = self.classes
                findCoursesViewController?.student = self.student
                findCoursesViewController?.studentClasses = self.studentClasses
                findCoursesViewController?.waitlist = self.waitlist
                findCoursesViewController?.studentClassDetails = self.classDetails
                findCoursesViewController?.waitlistDetails = self.waitlistDetails
            }
        case "showRegisteredCourseDetails"?:
            if segue.destination is UnregisterClassViewController {
                let unregisteredClassViewController = segue.destination as? UnregisterClassViewController
                
                // pass necessary details to UnregisterClassViewController
                unregisteredClassViewController?.student = self.student
                unregisteredClassViewController?.studentClasses = self.studentClasses
                unregisteredClassViewController?.waitlist = self.waitlist
                unregisteredClassViewController?.classDetails = self.classDetails
                unregisteredClassViewController?.waitlistDetails = self.waitlistDetails
                if let row = registeredClassesTableView.indexPathForSelectedRow?.row {
                    // Get info associated with row and pass it along
                    let details = classDetails![row]
                    unregisteredClassViewController?.details = details
                }
            }
        case "showWaitlistedCourseDetails"?:
            if segue.destination is UnwaitlistClassViewController {
                let unwaitlistClassViewController = segue.destination as? UnwaitlistClassViewController
                
                // pass necessary details to UnwaitlistClassViewController
                unwaitlistClassViewController?.student = self.student
                unwaitlistClassViewController?.studentClasses = self.studentClasses
                unwaitlistClassViewController?.waitlist = self.waitlist
                unwaitlistClassViewController?.classDetails = self.classDetails
                unwaitlistClassViewController?.waitlistDetails = self.waitlistDetails
                if let row = waitlistedClassesTableView.indexPathForSelectedRow?.row {
                    // Get info associated with row and pass it along
                    let details = waitlistDetails![row]
                    unwaitlistClassViewController?.details = details
                }
            }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
}

