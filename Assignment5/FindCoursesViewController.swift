//
//  FindCoursesViewController.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/16/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//

import UIKit

class FindCoursesViewController: UIViewController, UIPickerViewDelegate,
UIPickerViewDataSource {
    
    // MARK: vars
    
    // Used for the webservice functions
    var classIdsList = ClassIDsList()
    var classDetails = ClassDetails()
    
    // The registered and waitlisted courses in an array, and their details, and the students info
    // These variables will be passed around the view controllers
    var student: Student?
    var studentClasses: [Int]?
    var waitlist: [Int]?
    var studentClassDetails: [Details]?
    var waitlistDetails: [Details]?
    
    // stores information for the pickers
    var titles: [String]?
    var ids: [Int]?
    var colleges: [String]?
    var classes: [Int]?
    
    // set initial values for picker
    var startTimeHourPicked: String = ""
    var startTimeMinPicked: String = ""
    var endTimeHourPicked: String = ""
    var endTimeMinPicked: String = ""
    var parametersDict: [String: String] = ["subjectid": "26", "level": "", "starttime": "", "endtime": ""]
    
    // create empty arrays to hold the courses and details found
    var courseIds = [ClassID]()
    var details = [Details]()
    
    // MARK: lets
    
    let courseLevels = ["", "Lower", "Upper", "Graduate"]
    let timeHours = ["", "07", "08", "09", "10" ,"11", "12", "13", "14", "15", "16", "17", "18","19", "20", "21", "22"]
    let timeMins = ["", "00", "30"]
    
    // MARK: outlets
    
    @IBOutlet weak var subjectPicker: UIPickerView!
    @IBOutlet weak var courseLevelPicker: UIPickerView!
    @IBOutlet weak var startTimePicker: UIPickerView!
    @IBOutlet weak var endTimePicker: UIPickerView!
    
    // MARK: instance methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize pickers
        if subjectPicker != nil {
            subjectPicker!.delegate = self
            subjectPicker!.dataSource = self
        }
        
        if courseLevelPicker != nil {
            courseLevelPicker!.delegate = self
            courseLevelPicker!.dataSource = self
        }
        
        if startTimePicker != nil {
            startTimePicker!.delegate = self
            startTimePicker!.dataSource = self
        }
        
        if endTimePicker != nil {
            endTimePicker!.delegate = self
            endTimePicker!.dataSource = self
        }
    }
    
    // MARK: picker functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if (pickerView == subjectPicker || pickerView == courseLevelPicker) {
            return 1
        } else {
            return 2
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == subjectPicker  {
            return titles!.count
        } else if pickerView == courseLevelPicker {
            return courseLevels.count
        } else {
            switch component{
            case 0:
                return timeHours.count
            case 1:
                return timeMins.count
            default:
                return 0
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == subjectPicker {
            return titles!.sorted()[row]
        } else if pickerView == courseLevelPicker {
            return courseLevels[row]
        } else {
            switch component{
            case 0:
                return timeHours[row]
            case 1:
                return timeMins[row]
            default:
                return "None"
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == subjectPicker {
            let subject = titles!.sorted()[row]
            let index = titles!.firstIndex(of: subject)
            parametersDict["subjectid"] = "\(ids![index!])"
        } else if pickerView == courseLevelPicker {
            parametersDict["level"] = courseLevels[row].lowercased()
        }  else if pickerView == startTimePicker {
            switch component {
            case 0:
                startTimeHourPicked = timeHours[row]
            case 1:
                startTimeMinPicked = timeMins[row]
            default:
                break
            }
        } else {
            switch component {
            case 0:
                endTimeHourPicked = timeHours[row]
            case 1:
                endTimeMinPicked = timeMins[row]
            default:
                break
            }
        }
        parametersDict["starttime"] = startTimeHourPicked + startTimeMinPicked
        parametersDict["endtime"] = endTimeHourPicked + endTimeMinPicked
        
        // remove empty keys from dictionary parameter
        if parametersDict["level"] == "" {
            parametersDict.remove(at: parametersDict.index(forKey: "level")!)
        }
        if parametersDict["starttime"] == "" || parametersDict["starttime"]!.count != 4 {
            parametersDict.remove(at: parametersDict.index(forKey: "starttime")!)
        }
        if parametersDict["endtime"] == "" || parametersDict["endtime"]!.count != 4{
            parametersDict.remove(at: parametersDict.index(forKey: "endtime")!)
        }
        
        // reset courses and details array when pickers are changed
        courseIds = []
        details = []
        
        // get class Ids for filtered courses found
        classIdsList.fetchClassIDs(parameters: parametersDict) {
            (classIDsResult) -> Void in
            
            switch classIDsResult {
            
            // if successful, add course id to the courseIds array and get its details
            case let .success(courses):
                print("Successfully found \(courses.count) courses.")
                for id in courses {
                    let convertID = "\(id.id)"
                    self.courseIds.append(id)
                    self.getDetails(parameters: ["classid": convertID])
                }
            case let .failure(error):
                print("Error fetching courses: \(error)")
            }
        }
    }
    
    // MARK: webservice functions
    
    /*
     GET method
     grabs the class details for the courses ids
     */
    func getDetails(parameters: [String:String]) {
        classDetails.fetchClassDetails(parameters: parameters) {
            (classDetailsResult) -> Void in
            
            switch classDetailsResult {
            // if successful, add details to the details array
            case let .success(details):
                for id in details {
                    self.details.append(id)
                }
            case let .failure(error):
                print("Error fetching details: \(error)")
            }
        }
    }
    
    // MARK: segue functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showCourses"?:
            
            if segue.destination is CoursesFoundViewController {
                
                let coursesFoundViewController = segue.destination as? CoursesFoundViewController
                
                // pass necessary details to CoursesFoundViewController
                coursesFoundViewController?.courseIds = self.courseIds
                coursesFoundViewController?.details = self.details
                coursesFoundViewController?.student = self.student
                coursesFoundViewController?.studentClasses = self.studentClasses
                coursesFoundViewController?.waitlist = self.waitlist
                coursesFoundViewController?.studentClassDetails = self.studentClassDetails
                coursesFoundViewController?.waitlistDetails = self.waitlistDetails
            }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
}
