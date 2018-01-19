//
//  MainPagesViewController.swift
//  PickSkip
//
//  Created by Eric Duong on 7/11/17.
//  Copyright © 2017 Eric Duong. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import Contacts

class MainPagesViewController: UIPageViewController {

    var pages = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        //Appends the View Controllers from the Constants class
        for id in Constants.mainPagesViews {
            pages.append(storyboard!.instantiateViewController(withIdentifier: id))
        }
        
        //Prepares the first view controller to be displayed.
        setViewControllers([pages[Constants.initialViewPosition]], direction: .forward, animated: true, completion: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkPermissions()
    }
    
    func checkPermissions() {
        if(!(pages[Constants.initialViewPosition] as! CameraViewController).cameraloaded) {
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
                (self.pages[Constants.initialViewPosition] as! CameraViewController).setup()
            } else {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                    if granted == true {
                        (self.pages[Constants.initialViewPosition] as! CameraViewController).setup()
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///Adds login listener to automatically send users to the login screen if not logged in.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Util.addLoginCheckListener(self)

    }
    
    ///Removes login listener when the view disappears.
    override func viewWillDisappear(_ animated: Bool) {
        Util.removeCurrentLoginCheckListener()
    }
    
    public func sendToCamera() {
        pages[1].dismiss(animated: false, completion: nil)
    }
    
    public func showHistory() {
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
    }

}

//This class implements the UIPageViewController's Data Source so it can determine which View Controllers to display.
extension MainPagesViewController: UIPageViewControllerDataSource {
    
    ///This function determines what view controller to display next
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = pages.index(of: viewController)
        if index == nil || index! + 1 == pages.count {
            return nil
        } else {
            return pages[index!+1]
        }
    }
    
    ///This function determines what view controller to display previously
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = pages.index(of: viewController)
        if index == nil || index! == 0 {
            return nil
        } else {
            return pages[index!-1]
        }
    }
}
