//
//  TwitterClient.swift
//  twitter-oauth-demo
//
//  Created by mny on 2/7/16.
//  Copyright © 2016 ccsf. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let twitterBaseUrl = NSURL(string: "https://api.twitter.com")
let twitterConsumerKey = ""
let twitterConsumerSecret = ""

class TwitterClient: BDBOAuth1SessionManager {
    
    var loginCompletion: ( (user: User?, error: NSError?) -> () )?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(
                baseURL: twitterBaseUrl,
                consumerKey: twitterConsumerKey,
                consumerSecret: twitterConsumerSecret)
        }
        
        return Static.instance
    }
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        
        loginCompletion = completion
        
        //Fetch request token + redirect to login page
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath(
            "oauth/request_token",
            method: "GET",
            callbackURL: NSURL(string: "cputwitterdemo://oauth"),
            scope: nil,
            success: {
                (requestToken: BDBOAuth1Credential!) -> Void in
                print("Got the request token")
                
                let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
                
                UIApplication.sharedApplication().openURL(authURL!)
                
            }) {
                (error: NSError!) -> Void in
                print("Failed to get request token")
                self.loginCompletion?(user: nil, error: error)
        }
        
    }
    
    func openURL(url: NSURL) {
        
        fetchAccessTokenWithPath(
            "oauth/access_token",
            method: "POST",
            requestToken: BDBOAuth1Credential(queryString: url.query),
            success: { (accessToken: BDBOAuth1Credential!) -> Void in
                print("Got the access token!")
                
                TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
                
                TwitterClient.sharedInstance.GET(
                    "1.1/account/verify_credentials.json",
                    parameters: nil,
                    success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
                        //print("user: \(response!)")
                        
                        let user = User(dictionary: response as! NSDictionary)
                        print("user = \(user.name!)")
                        
                        self.loginCompletion?(user: user, error: nil)
                        
                    },
                    failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                        print("error getting current user")
                        self.loginCompletion?(user: nil, error: error)
                        
                })
                
                TwitterClient.sharedInstance.GET(
                    "1.1/statuses/home_timeline.json",
                    parameters: nil,
                    success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
                        //print("home_timeline: \(response!)")
                        
                        let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
                        for tweet in tweets {
                            print("tweet text: \(tweet.text!)")
                            print("created: \(tweet.createdAtString!)")
                            print("")
                        }
                    },
                    failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                        print("error getting home timeline tweets")
                        
                })
                
            },
            failure: { (error: NSError!) -> Void in
                print("Failed to receive access token")
                self.loginCompletion?(user: nil, error: error)
        })

    }


}
