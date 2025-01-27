//
//  PhoneNumberVerificationViewController.swift
//  PickSkip
//
//  Created by Eric Duong on 7/14/17.
//  Copyright © 2017 Eric Duong. All rights reserved.
//

import UIKit
import Firebase

class PhoneNumberVerificationViewController: UIViewController {
    @IBOutlet weak var activityIndicatorSpinner: UIActivityIndicatorView!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var verifyPrompt: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        verifyButton.layer.cornerRadius = 20
        verifyButton.layer.borderWidth = 2
        verifyButton.layer.borderColor = Constants.defaultBlueColor.cgColor
        verificationCodeTextField.textColor = Constants.defaultBlueColor
        
        verifyPrompt.minimumScaleFactor = 0.2
        verifyPrompt.adjustsFontSizeToFitWidth = true
        activityIndicatorSpinner.hidesWhenStopped = true
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            dismiss(animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///Called when user hits "verify"
    @IBAction func verifyCode(_ sender: Any) {
        
        //Start spinner and disable user input
        activityIndicatorSpinner.startAnimating()
        view.isUserInteractionEnabled = false
        
        //Retrieve saved verification ID and attempt to create login credentials.
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") ?? ""
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCodeTextField.text!)
        
        //Use credentials to attempt to sign in.
        Auth.auth().signIn(with: credential) {
            user, error in
            //When response received, stop spinner and re-enable user input
            //If response is an error, display error message.
            if let error = error {
                self.errorMessage.text = "Verification Error: \(error)"
                self.errorMessage.isHidden = false
                return
            } else {
                DataService.instance.doesUserExist(number: user!.providerData[0].phoneNumber!) {(exists) in
                    if exists {
                        self.activityIndicatorSpinner.stopAnimating()
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let mainViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.window?.rootViewController = mainViewController
                    } else {
                        self.performSegue(withIdentifier: "contactFormSegue", sender: self)
                    }
                    self.view.isUserInteractionEnabled = true
                    self.view.endEditing(true)
                }
            }
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
