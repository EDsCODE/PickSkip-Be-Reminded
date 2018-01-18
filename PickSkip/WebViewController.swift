//
//  WebViewController.swift
//  PickSkip
//
//  Created by Eric Duong on 8/22/17.
//  Copyright © 2017 Eric Duong. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var webAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //eliminates gray bar at the top of webview
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
