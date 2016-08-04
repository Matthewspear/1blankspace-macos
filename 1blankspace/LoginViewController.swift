//
//  LoginViewController.swift
//  1blankspace
//
//  Created by Matthew Spear on 04/08/2016.
//  Copyright © 2016 Matthew Spear. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController
{
  @IBOutlet var loginTextField: NSTextField!
  @IBOutlet var passwordTextField: NSSecureTextField!
  @IBOutlet var rememberButton: NSButton!
  @IBOutlet var progressIndicator: NSProgressIndicator!
  @IBOutlet var errorTextField: NSTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  @IBAction func cancelAction(sender: NSButton)
  {
    print("Cancel Pressed")
  }
  
  @IBAction func loginAction(sender: NSButton)
  {
    print("Login Pressed")
    print(rememberButton.state)
  }
}