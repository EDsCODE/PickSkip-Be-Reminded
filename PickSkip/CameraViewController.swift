//
//  CameraViewController.swift
//  PickSkip
//
//  Created by Aaron Kau on 7/10/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import Contacts

class CameraViewController: UIViewController {
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var recordButton: RecordButton!
    @IBOutlet weak var feedButton: UIButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    
    var image: UIImage!
    var video: URL!
    var cameraloaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(!cameraloaded) {
            if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized {
                feedButton.imageView?.contentMode = .scaleAspectFit
                //Set up Camera View
                
                flipCameraButton.imageView?.contentMode = .scaleAspectFit
                cameraView.delegate = self
                
                cameraView.setupCameraView(recordButton)
                cameraloaded = true
            } else {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted: Bool) -> Void in
                    if granted == true {
                        self.feedButton.imageView?.contentMode = .scaleAspectFit
                        //Set up Camera View
                        
                        self.flipCameraButton.imageView?.contentMode = .scaleAspectFit
                        self.cameraView.delegate = self
                        
                        self.cameraView.setupCameraView(self.recordButton)
                        self.cameraloaded = true
                    } else {
                        let alert = UIAlertController(title: nil, message: "This app requires access to your camera to proceed. Please open settings and grant permission to camera.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
                            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
                        })
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
        
        if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            DispatchQueue.global(qos: .userInteractive).async {
                Util.loadContacts(completion: nil)
            }
        } else {
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                if granted {
                    DispatchQueue.global(qos: .userInteractive).async {
                        Util.loadContacts(completion: nil)
                    }
                } else {
                    let alert = UIAlertController(title: nil, message: "This app requires access to your contacts to proceed. Please open settings and grant permission to camera", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
                    })
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func flipCamera(_ sender: Any) {
        cameraView.flipCamera()
    }


    @IBAction func goToFeed(_ sender: Any) {
        if let parentController = self.parent as? MainPagesViewController {
            parentController.setViewControllers([parentController.pages[0]], direction: .reverse, animated: true, completion: nil)
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPreview" {
            let destination = segue.destination as? PreviewController
            if let image = image {
                destination?.image = image
                self.image = nil
            } else if let video = video {
                destination?.video = video
                self.video = nil
            }
        }
        
    }
}

extension CameraViewController: CameraViewDelegate {
    
    ///Accepts an image, displays it on the PreviewView.
    func submit(image: UIImage) {
        self.image = image
        self.performSegue(withIdentifier: "showPreview", sender: self)
    }
    
    ///Accepts a video, displays it on the PreviewView.
    func submit(videoURL: URL) {
        self.video = videoURL
        self.performSegue(withIdentifier: "showPreview", sender: self)
    }
    
    func showSettings(){
        let alertController = UIAlertController (title: "Permission Request", message: "This is a camera app that requires access to your phone's camera. Please go to the settings page and allow PickSkip to your phone's camera.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
