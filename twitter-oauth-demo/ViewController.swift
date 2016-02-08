//
//  ViewController.swift
//  twitter-oauth-demo
//
//  Created by mny on 2/7/16.
//  Copyright © 2016 ccsf. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onLogin(sender: AnyObject) {
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
        TwitterClient.sharedInstance.fetchRequestTokenWithPath(
                "oauth/request_token",
                method: "GET",
                callbackURL: NSURL(string: "cptwitter://oauth"),
                scope: nil,
                success: {
                        (requestToken: BDBOAuth1Credential!) -> Void in
                            print("Got the request token")
            }) {
                (error: NSError!) -> Void in
                    print("Failed to get request token")
            }
    }


}

