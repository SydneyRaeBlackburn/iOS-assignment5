//
//  UnregisterClassViewController.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/19/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//

import UIKit

class UnregisterClassViewController: UIViewController, UITextFieldDelegate {
    
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
    
    @IBAction func unregisterButton(_ sender: UIButton) {
        
        // add an alert before unregistering the student from the course
        
        let title = "Delete Course"
        let message = "Are you sure you want to unregister this course?"
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        
        let unregisterAction = UIAlertAction(title: "Unregister", style: .destructive, handler: { (action) -> Void in
            
            // set courseId from the details and unregister the student from the course
            self.courseId = self.details!.id
            self.unregisterStudent(redid: self.student!.redid, password: self.student!.password, courseid: self.details!.id)
        })
        
        ac.addAction(unregisterAction)
        
        present(ac, animated: true, completion: nil)
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
     creates a URL to send to the server to unregister the student from the course
     */
    func unregisterStudent(redid: String, password: String, courseid: Int) {
        
        // URL parameters
        let json: [String:Any] = ["redid":redid, "password":password, "courseid":courseId]
        
        // create JSON object
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        
        // create URL
        if let url = URL(string: "https://bismarck.sdsu.edu/registration/unregisterclass") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let session = URLSession.shared
            let task = session.uploadTask(with: request, from: jsonData, completionHandler: uploadResponse)
            task.resume()
        } else {
            print("Unable to create URL")
        }
    }
    
    /*
     unregisters the student from the course
     returns a JSON object with one key, either "ok" or "error"
     */
    func uploadResponse(data:Data?, response:URLResponse?, error:Error?) -> Void {
        
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
                    OperationQueue.main.addOperation {
                        self.performSegue(withIdentifier: "showMyClasses", sender: self)
                    }
                } else {
                    print("Error: \(json.first!.key)")
                }
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: segue functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showMyClasses"?:
            if segue.destination is MyClassesViewController {
                let myClassesViewController = segue.destination as? MyClassesViewController
               
                // pass necessary details to MyClassesViewController
                myClassesViewController?.student = self.student
                myClassesViewController?.waitlist = self.waitlist
                myClassesViewController?.waitlistDetails = self.waitlistDetails
                
                // remove unregistered course from the registered classes array
                // also remove the unregistered course details from the details array
                myClassesViewController?.studentClasses = self.studentClasses!.filter{ $0 != self.courseId }
                var index: Int = 0
                for detail in (self.classDetails)! {
                    if detail.id == self.courseId {
                        self.classDetails!.remove(at: index)
                        break
                    }
                    index += 1
                }
                myClassesViewController?.classDetails = self.classDetails
            }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
    
}
