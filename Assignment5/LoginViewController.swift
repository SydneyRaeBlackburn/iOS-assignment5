//
//  LoginViewController.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/14/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: vars
    
    // Used for the webservice function
    var details = ClassDetails()
    var myClasses = MyClassesViewController()
    
    // The registered and waitlisted courses in an array, and their details, and the students info
    // These variables will be passed around the view controllers
    var classDetails = [Details]()
    var waitlistDetails = [Details]()
    var classes: [Int] = [Int]()
    var waitlist: [Int] = [Int]()
    var student: Student?
    
    // counts used to make sure getDetails functions are only once per course
    var classesCount: Int = 0
    var waitlistCount: Int = 0
    var count: Int = 0
    var countTwo: Int = 0
    
    // MARK: outlets
    
    @IBOutlet var requiredLabel: UILabel!
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var lastNameLabel: UILabel!
    @IBOutlet var sdsuRedIDLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var passwordLabel: UILabel!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var sdsuRedIDTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    // MARK: actions
    
    @IBAction func registerButton(_ sender: UIButton) {
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        // store students personal information
        
        guard let firstname = firstNameTextField.text, !firstname.isEmpty,
            let lastname = lastNameTextField.text, !lastname.isEmpty,
            let redid = sdsuRedIDTextField.text, !redid.isEmpty,
            let password = passwordTextField.text, !password.isEmpty,
            let email = emailTextField.text, !email.isEmpty else {
            
                requiredLabel.textColor = .red
                print("All fields required")
                return
        }
        
        // create a student instance and get the students waitlisted and registered classes
        student = Student(firstName: firstname, lastName: lastname, redid: redid, password: password, email: email)
        classes(redid: redid, password: password)
        
        // save students information
        
        UserDefaults.standard.set(firstname, forKey: "firstname")
        UserDefaults.standard.set(lastname, forKey: "lastname")
        UserDefaults.standard.set(redid, forKey: "redid")
        UserDefaults.standard.set(email, forKey: "email")
        
    }
    
    // MARK: instance methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Save changes to name field in User Defaults to pass around later
        firstNameTextField.text = "\(UserDefaults.standard.string(forKey: "firstname") ?? "")"
        lastNameTextField.text = "\(UserDefaults.standard.string(forKey: "lastname") ?? "")"
        sdsuRedIDTextField.text = "\(UserDefaults.standard.string(forKey: "redid") ?? "")"
        emailTextField.text = "\(UserDefaults.standard.string(forKey: "email") ?? "")"
        
    }
    
    // MARK: webservice functions
    
    /*
     POST method
     creates a URL to send to the server to grab the classes the student is enrolled in
    */
    func classes(redid: String, password: String) {
        // URL paramters
        let json: [String:Any] = ["redid":redid, "password":password]
        
        // create JSON object
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        
        // create URL
        if let url = URL(string: "https://bismarck.sdsu.edu/registration/studentclasses") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let session = URLSession.shared
            let task = session.uploadTask(with: request, from: jsonData, completionHandler: downloadClasses)
            task.resume()
        } else {
            print("Unable to create URL")
        }
    }
    
    /*
     grabs the students registered courses
     returns a JSON array of class ids with two keys: "classes" and "waitlist"
     */
    func downloadClasses(data:Data?, response:URLResponse?, error:Error?) -> Void {
        
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
            if let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: [Int]] {
                
                // set vars from JSON data
                self.myClasses.studentClasses = json["classes"]
                self.classes = json["classes"]!
                self.classesCount = self.classes.count
                self.myClasses.waitlist = json["waitlist"]
                self.waitlist = json["waitlist"]!
                self.waitlistCount = self.waitlist.count
                
                // get details for each class student is enrolled and waitlisted in
                for id in self.classes {
                    let convertID = "\(id)"
                    self.getClassDetails(parameters: ["classid": convertID])
                }
                for id in self.waitlist {
                    let convertID = "\(id)"
                    self.getWaitlistDetails(parameters: ["classid": convertID])
                }
                
                // there are no classes the student is waitlisted or enrolled in
                if self.classes.isEmpty && self.waitlist.isEmpty {
                    OperationQueue.main.addOperation {
                        self.performSegue(withIdentifier: "studentClasses", sender: self)
                    }
                }
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /*
     GET method
     grabs the class details for courses the student is enrolled in
     */
    func getClassDetails(parameters: [String:String]) {
        details.fetchClassDetails(parameters: parameters) {
            (classDetailsResult) -> Void in
            
            switch classDetailsResult {
                
            // if successful, get details for each class in registered classes array
            case let .success(details):
                self.count += 1
                for id in details {
                    self.classDetails.append(id)
                }
                
                // perform segue when each registered class has received it's details
                if self.waitlist.isEmpty && self.count == self.classesCount{
                    OperationQueue.main.addOperation {
                        self.performSegue(withIdentifier: "studentClasses", sender: self)
                    }
                }
            case let .failure(error):
                print("Error fetching details: \(error)")
            }
        }
    }
    
    /*
     GET method
     grabs the class details for courses the student is waitlisted in
     */
    func getWaitlistDetails(parameters: [String:String]) {
        details.fetchClassDetails(parameters: parameters) {
            (classDetailsResult) -> Void in
            
            switch classDetailsResult {
                
            // if successful, get details for each class in waitlisted classes array
            case let .success(details):
                self.countTwo += 1
                for id in details {
                    self.waitlistDetails.append(id)
                }
                
                // perform segue when each waitlisted class has received it's details
                if self.countTwo == self.waitlistCount {
                    OperationQueue.main.addOperation {
                        self.performSegue(withIdentifier: "studentClasses", sender: self)
                    }
                }
                
            case let .failure(error):
                print("Error fetching details: \(error)")
            }
        }
    }
    
    // MARK: segue functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "studentClasses"?:
            if segue.destination is MyClassesViewController {
                
                // pass necessary details to MyClassesViewController
                let myClassesViewController = segue.destination as? MyClassesViewController
                myClassesViewController?.student = self.student
                myClassesViewController?.studentClasses = self.classes
                myClassesViewController?.waitlist = self.waitlist
                myClassesViewController?.classDetails = self.classDetails
                myClassesViewController?.waitlistDetails = self.waitlistDetails
            }
        case "register":
            print("Register new student")
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
}
