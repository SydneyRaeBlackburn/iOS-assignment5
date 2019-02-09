//
//  RegisterViewController.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/15/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//


import UIKit

class RegisterViewController: UIViewController {
    
    // MARK: vars
    
    // The students info
    // This variables will be passed around the view controllers
    var student: Student?
    
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
        
        // create a student instance and add the students personal information to the server
        addStudent(firstname: firstname, lastname: lastname, redid: redid, password: password, email: email)
        student = Student(firstName: firstname, lastName: lastname, redid: redid, password: password, email: email)
    }
    
    // MARK: webservice functions
    
    /*
     POST method
     creates a URL to send to the server to add the student
     */
    func addStudent(firstname: String, lastname: String, redid: String, password: String, email: String) {
        
        // URL parameters
        let json: [String:Any] = ["firstname":firstname, "lastname":lastname, "redid":redid, "password":password, "email":email]
        
        // create JSON object
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        
        
        // create URL
        if let url = URL(string: "https://bismarck.sdsu.edu/registration/addstudent") {
            var request = URLRequest.init(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let session = URLSession.shared
            let task = session.uploadTask(with: request, from: jsonData, completionHandler: uploadResponse)
            task.resume()
        } else {
            print("Unable to create URL")
        }
        
        requiredLabel.textColor = .white
    }
    
    /*
     uploads student information to server
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
                
                // perform segue if JSON object returns "ok"
                if json.first!.key == "ok" {
                    OperationQueue.main.addOperation {
                        self.performSegue(withIdentifier: "studentClasses", sender: self)
                    }
                // if JSON object return "error", then display an error message
                } else {
                    OperationQueue.main.addOperation {
                        self.requiredLabel.text = "* \(json.first!.value)"
                        self.requiredLabel.textColor = .red
                    }
                }
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: segue functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "studentClasses"?:
            if segue.destination is MyClassesViewController {
                let myClassesViewController = segue.destination as? MyClassesViewController
                
                // pass necessary details to MyClassesViewController
                // set registered and waitlisted classes and their details to empty
                myClassesViewController?.student = self.student
                myClassesViewController?.classDetails = [Details]()
                myClassesViewController?.waitlistDetails = [Details]()
                myClassesViewController?.studentClasses = [Int]()
                myClassesViewController?.waitlist = [Int]()
            }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
}

