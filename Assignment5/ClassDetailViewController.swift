//
//  ClassDetailViewController.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/18/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//

import UIKit

class ClassDetailViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: vars
    
    // The registered and waitlisted courses in an array, and their details, and the students info
    // These variables will be passed around the view controllers
    var student: Student?
    var studentClasses: [Int]?
    var waitlist: [Int]?
    var classDetails: [Details]?
    var waitlistDetails: [Details]?
    
    // stores the details of the course clicked on
    var details: Details?
    
    // displays how many seats are available in the details
    var availableSeats: Int?
    
    // used as a parameter for the unregisteStudent function
    var courseId: Int = 0
    
    // MARK: outlets
    
    @IBOutlet weak var subjectAndCourseNumLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var scheduleNumLabel: UILabel!
    @IBOutlet weak var unitsLabel: UILabel!
    @IBOutlet weak var enrolledAndSeatsLabel: UILabel!
    @IBOutlet weak var waitlistLabel: UILabel!
    @IBOutlet weak var meetingTypeLabel: UILabel!
    @IBOutlet weak var startAndEndTimeLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var buildingAndRoomLabel: UILabel!
    @IBOutlet weak var instructorLabel: UILabel!
    @IBOutlet weak var fullTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var prerequisiteLabel: UILabel!
    
    // MARK: actions
    
    @IBAction func registerButton(_ sender: UIButton) {
        
        // set courseId from the details and register the student for the course
        self.courseId = details!.id
        self.registerStudent(redid: String(self.student!.redid), password: self.student!.password, courseid: self.details!.id)
        
    }
    @IBAction func waitlistButton(_ sender: UIButton) {
        
        // set courseId from the details and waitlist the student for the course
        self.courseId = details!.id
        self.waitlistStudent(redid: self.student!.redid, password: self.student!.password, courseid: self.details!.id)
    }
    
    // MARK: instance methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // calculate amounts of available seats
        if let seats = details?.seats, let enrolled = details?.enrolled {
            availableSeats = seats - enrolled
        }
        
        // set the outlets to the details of the course
        subjectAndCourseNumLabel.text = "\(details?.subject ?? "") \(details?.courseNum ?? "")"
        titleLabel.text = "\(details?.title ?? "")"
        sectionLabel.text = "\(details?.section ?? "")"
        scheduleNumLabel.text = "\(details?.scheduleNum ?? "")"
        unitsLabel.text = "\(details?.units ?? "")"
        enrolledAndSeatsLabel.text = "\(availableSeats ?? 0)/\(details?.seats ?? 0)"
        waitlistLabel.text = "\(details?.waitlist ?? 0)"
        meetingTypeLabel.text = "\(details?.meetingType ?? "")"
        startAndEndTimeLabel.text = "\(details?.startTime ?? "") - \(details?.endTime ?? "")"
        daysLabel.text = "\(details?.days ?? "")"
        buildingAndRoomLabel.text = "\(details?.building ?? "") - \(details?.room ?? "")"
        instructorLabel.text = "\(details?.instructor ?? "")"
        fullTitleLabel.text = "\(details?.fullTitle ?? "")"
        descriptionLabel.text = "\(details?.description ?? "")"
        prerequisiteLabel.text = "\(details?.prerequisite ?? "")"
        
    }
    
    // MARK: webservice functions
    
    /*
     POST method
     creates a URL to send to the server to register the student for the course
     */
    func registerStudent(redid: String, password: String, courseid: Int) {
        
        // URL parrameters
        let json: [String:Any] = ["redid":redid, "password":password, "courseid":courseId]
        
        // create JSON object
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        
        // create URL
        if let url = URL(string: "https://bismarck.sdsu.edu/registration/registerclass") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let session = URLSession.shared
            let task = session.uploadTask(with: request, from: jsonData, completionHandler: uploadRegisterResponse)
            task.resume()
        } else {
            print("Unable to create URL")
        }
    }
    
    /*
     registers the student for the course
     returns a JSON object with one key, either "ok" or "error"
     */
    func uploadRegisterResponse(data:Data?, response:URLResponse?, error:Error?) -> Void {
        
        // error handling
        guard error == nil else {
            print("Error: \(error!)")
            return
        }
        let httpResponse = response as? HTTPURLResponse
        let status:Int = httpResponse!.statusCode
        if status != 200, let error = String(data: data!, encoding: String.Encoding.utf8) {
            print("Error: \(error)")
            return
        }
        do {
            //create json object from data
            if let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: String] {
                print(json)
                
                // if succesful, go back to MyClassesViewController
                if json.first!.key == "ok" {
                    print(json.first!.value)
                    OperationQueue.main.addOperation {
                        self.performSegue(withIdentifier: "registerShowMyClasses", sender: self)
                    }
                } else {
                    print(json.first!.value)
                }
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /*
     POST method
     creates a URL to send to the server to waitlist the student for the course
     */
    func waitlistStudent(redid: String, password: String, courseid: Int) {
        
        // URL parameters
        let json: [String:Any] = ["redid":redid, "password":password, "courseid":courseId]
        
        // create JSON object
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        
        // create URL
        if let url = URL(string: "https://bismarck.sdsu.edu/registration/waitlistclass") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let session = URLSession.shared
            let task = session.uploadTask(with: request, from: jsonData, completionHandler: uploadWaitlistResponse)
            task.resume()
        } else {
            print("Unable to create URL")
        }
    }
    
    /*
     waitlists the student for the course
     returns a JSON object with one key, either "ok" or "error"
     */
    func uploadWaitlistResponse(data:Data?, response:URLResponse?, error:Error?) -> Void {
        
        // error handling
        guard error == nil else {
            print("Error: \(error!)")
            return
        }
        let httpResponse = response as? HTTPURLResponse
        let status:Int = httpResponse!.statusCode
        if status != 200, let error = String(data: data!, encoding: String.Encoding.utf8) {
            print("Error: \(error)")
            return
        }
        do {
            //create json object from data
            if let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: String] {
                print(json)
                
                // if successful, go back to MyClassesViewController
                if json.first!.key == "ok" {
                    print(json.first!.value)
                    OperationQueue.main.addOperation {
                        self.performSegue(withIdentifier: "waitlistShowMyClasses", sender: self)
                    }
                } else {
                    print(json.first!.value)
                }
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: segue functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "registerShowMyClasses"?:
            if segue.destination is MyClassesViewController {
                let myClassesViewController = segue.destination as? MyClassesViewController
                
                // pass necessary details to MyClassesViewController
                // if any array is nil, initialize it to empty
                myClassesViewController?.student = self.student
                if self.studentClasses == nil {
                    self.studentClasses = [self.courseId]
                    myClassesViewController?.studentClasses = self.studentClasses
                } else {
                    self.studentClasses?.append(self.courseId)
                    myClassesViewController?.studentClasses = self.studentClasses
                }
                if self.classDetails == nil {
                    self.classDetails = [self.details!]
                    myClassesViewController?.classDetails = self.classDetails
                } else {
                    self.classDetails?.append(self.details!)
                    myClassesViewController?.classDetails = self.classDetails
                }
                if self.waitlist == nil {
                    self.waitlist = []
                    myClassesViewController?.waitlist = self.waitlist
                } else {
                    myClassesViewController?.waitlist = self.waitlist
                }
                if self.waitlistDetails == nil {
                    self.waitlistDetails = []
                    myClassesViewController?.waitlistDetails = self.waitlistDetails
                } else {
                    myClassesViewController?.waitlistDetails = self.waitlistDetails
                }
            }
        case "waitlistShowMyClasses"?:
            if segue.destination is MyClassesViewController {
                print(self.waitlist ?? "None")
                let myClassesViewController = segue.destination as? MyClassesViewController
                
                // pass necessary details to MyClassesViewController
                // if any array is nil, initialize it to empty
                myClassesViewController?.student = self.student
                if self.waitlist == nil {
                    self.waitlist = [self.courseId]
                    myClassesViewController?.waitlist = self.waitlist
                } else {
                    self.waitlist?.append(self.courseId)
                    myClassesViewController?.waitlist = self.waitlist
                }
                if self.waitlistDetails == nil {
                    self.waitlistDetails = [details!]
                    myClassesViewController?.waitlistDetails = self.waitlistDetails
                } else {
                    self.waitlistDetails?.append(details!)
                    myClassesViewController?.waitlistDetails = self.waitlistDetails
                }
                if self.studentClasses == nil {
                    self.studentClasses = []
                    myClassesViewController?.studentClasses = self.studentClasses
                } else {
                    myClassesViewController?.studentClasses = self.studentClasses
                }
                if self.classDetails == nil {
                    self.classDetails = []
                    myClassesViewController?.classDetails = self.classDetails
                } else {
                    myClassesViewController?.classDetails = self.classDetails
                }
            }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
}
