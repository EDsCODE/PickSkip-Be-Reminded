//
//  LoginViewController.swift
//  PickSkip
//
//  Created by Eric Duong on 7/14/17.
//  Copyright © 2017 Eric Duong. All rights reserved.
//

import UIKit
import Firebase
import PhoneNumberKit
import Contacts
import AVFoundation

class LoginViewController: UIViewController {

    @IBOutlet weak var activityIndicatorSpinner: UIActivityIndicatorView!
    @IBOutlet weak var phoneNumberTextField: PhoneNumberTextField!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        
        loginButton.layer.cornerRadius = 20
        loginButton.layer.borderWidth = 2
        loginButton.layer.borderColor = UIColor(displayP3Red: 33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0).cgColor
        phoneNumberTextField.textColor = UIColor(displayP3Red: 33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        promptLabel.minimumScaleFactor = 0.2
        promptLabel.adjustsFontSizeToFitWidth = true
        activityIndicatorSpinner.hidesWhenStopped = true
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///Called when the user submits their phone number.
    @IBAction func submitNumber(_ sender: Any) {
        //Start spinner and disable user input
        activityIndicatorSpinner.startAnimating()
        view.isUserInteractionEnabled = false
        
        //Attempt to parse phone number.
        let phoneNumberKit = PhoneNumberKit()
        do {
            let phoneNumber = try phoneNumberKit.parse(phoneNumberTextField.text!)
            let parsedNumber = phoneNumberKit.format(phoneNumber, toType: .e164)
            
            //If parse successful, connect to firebase and attempt to verify.
            PhoneAuthProvider.provider().verifyPhoneNumber(parsedNumber, uiDelegate: nil) { (verificationID, error) in
                //When response received, stop spinner and re-enable user input
                self.view.isUserInteractionEnabled = true
                self.activityIndicatorSpinner.stopAnimating()
                //If response received is an error, print the error.
                if let error = error {
                    self.errorMessage.text = "Phone Number Verification Error: \(error.localizedDescription)"
                    self.errorMessage.isHidden = false
                    return
                }
                //Otherwise, send to verification page.
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                self.view.endEditing(true)
                self.performSegue(withIdentifier: "loginToVerification", sender: nil)
            }
            //If phone number parsing fails, print error.
        } catch {
            self.view.isUserInteractionEnabled = true
            self.activityIndicatorSpinner.stopAnimating()
            self.errorMessage.text = "Phone Number parsing error! Please enter a valid phone number!"
            self.errorMessage.isHidden = false
        }
    }
    
    ///Attempt to authenticate before asking for phone number.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for  subView in phoneNumberTextField.subviews {
            if let label = subView as? UILabel {
                label.minimumScaleFactor = 0.1
                label.adjustsFontSizeToFitWidth = true
            }
        }
        if Auth.auth().currentUser != nil {
            DataService.instance.saveUser()
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    ///Force keyboard to close when tapping on the view.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
