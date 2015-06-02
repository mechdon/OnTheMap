//
//  ViewController.swift
//  OnTheMap
//
//  Created by Gerard Heng on 21/5/15.
//  Copyright (c) 2015 gLabs. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    // Textfield outlets for userEmail and Password
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.userEmail.delegate = self
        self.userPassword.delegate = self
        
        // Check Current Access Token for Facebook and perform seque to Tab Bar Controller if available
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            performSequetoTabBarController()
        }
        else
        {
            // Present Facebook Login Button
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.frame = CGRectMake(0, 520, 288, 40)
            loginView.center.x = self.view.center.x
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
    }
    
    // Textfield resigns first responder when return key is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Go to Udacity Sign-Up Page
    @IBAction func signupButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    
    // Login Button Pressed
    @IBAction func loginButtonPressed(sender: AnyObject) {
        
        // Check if device is connected to the Internet
        if Reachability.isConnectedToNetwork() == false {
        showAlertMsg("Connection Error", errorMsg: "Unable to connect to the internet. Please check your connection")
        }
        
        var username:String = userEmail.text
        var password:String = userPassword.text
        
        // Prompt user to enter email if emailUsername field is empty
        if username.isEmpty {
        showAlertMsg("Login Error", errorMsg: "Please enter your email as username")
        }
        
        // Prompt user to enter password if password field is empty
        if password.isEmpty {
        showAlertMsg("Login Error", errorMsg: "Please enter your password")
        }
        
        // Perform Login Method using username and password entered by user
        Client.sharedInstance().udacityLogin(username, password: password, completionHandler: { (success, error) in
            if success {
                self.performSequetoTabBarController()
            } else {
                self.showAlertMsg("Login Error", errorMsg: error!)
            }
        })
    }
    
    // Function to perform seque to Tab Bar Controller
    func performSequetoTabBarController() {
        NSOperationQueue.mainQueue().addOperationWithBlock{
            self.performSegueWithIdentifier("tabBarController", sender: self)
        }
    }
    
    // Show Alert Method
    func showAlertMsg(errorTitle: String, errorMsg: String) {
        var title = errorTitle
        var errormsg = errorMsg
        
        NSOperationQueue.mainQueue().addOperationWithBlock{ var alert = UIAlertController(title: title, message: errormsg, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    //# MARK: - Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if ((error) != nil)
        {
            // Process error
            self.showAlertMsg("FBLogin Error", errorMsg: "Unable to log in to Facebook")
        }
        else if result.isCancelled {
            // Handle cancellations
            self.showAlertMsg("Cancel", errorMsg: "Cancel Facebook Login")
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
            returnUserData()
            performSegueWithIdentifier("tabBarController", sender: self)
        }
        
    }
    
    // Facebook Logout
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    }
    
    // Obtain User Data via Facebook Login
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                self.showAlertMsg("FBLogin Error", errorMsg: "Unable to retrieve user data")
            }
            else
            {
                let firstName: String = result.valueForKey("first_name") as! String
                let lastName: String = result.valueForKey("last_name") as! String
                let uniqueKey: String = result.valueForKey("id") as! String
                NSUserDefaults.standardUserDefaults().setObject(firstName, forKey: "firstName")
                NSUserDefaults.standardUserDefaults().setObject(lastName, forKey: "lastName")
                NSUserDefaults.standardUserDefaults().setObject(uniqueKey, forKey: "uniqueKey")
            }
        })
    }

}

