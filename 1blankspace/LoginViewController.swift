//
//  LoginViewController.swift
//  1blankspace
//
//  Created by Matthew Spear on 04/08/2016.
//  Copyright © 2016 Matthew Spear. All rights reserved.
//

import Cocoa
import KeychainAccess

class LoginViewController: NSViewController
{
  @IBOutlet var loginTextField: NSTextField!
  @IBOutlet var passwordTextField: NSSecureTextField!
  @IBOutlet var rememberButton: NSButton!
  @IBOutlet var progressIndicator: NSProgressIndicator!
  @IBOutlet var errorTextField: NSTextField!
  
  @IBOutlet var cancelButton: NSButton!
  @IBOutlet var loginButton: NSButton!
  
  var sid: String?
  
  var username: String
  {
    return loginTextField.stringValue
  }
  
  var password: String
  {
    return passwordTextField.stringValue
  }

  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    loginTextField.delegate = self
    passwordTextField.delegate = self
    
    rememberButton.state = userDefaults.boolForKey("rememberMe") ? 1 : 0
    
    if userDefaults.boolForKey("rememberMe")
    {
      loginTextField.stringValue = userDefaults.stringForKey("username") ?? ""
      passwordTextField.stringValue = keychain[username] ?? ""
    }
  }
  
  func loginInUser()
  {
    print("\(username) - \(password)")
    
    API.login(username, password: password, completion: { result in
      
      print(result)
      self.sid = result
      
      self.enableView()
      self.progressIndicator.stopAnimation(self)
      
    }) { error in
      
      // present error here, using error code
      print(error)
      
      self.errorTextField.hidden = false
      
      self.enableView()
      self.progressIndicator.stopAnimation(self)
    }
  }
  
  func disableView()
  {
    loginTextField.enabled = false
    passwordTextField.enabled = false
    rememberButton.enabled = false
    loginButton.enabled = false
    
    errorTextField.hidden = true
  }
  
  func enableView()
  {
    loginTextField.enabled = true
    passwordTextField.enabled = true
    rememberButton.enabled = true
    loginButton.enabled = true
  }
  
  func updateKeychain()
  {
    switch rememberButton.state
    {
    case 0:
      print("deleting password")
      keychain[username] = nil
      userDefaults.setBool(false, forKey: "rememberMe")
      
    case 1:
      print("storing password")
      keychain[username] = password
      userDefaults.setBool(true, forKey: "rememberMe")
      
    default: break
    }
  }
  
  @IBAction func loginAction(sender: NSButton)
  {
    loginInUser()
    progressIndicator.startAnimation(nil)
    disableView()
    
    updateKeychain()
    userDefaults.setObject(username, forKey: "username")
    userDefaults.synchronize()
  }
  
  @IBAction func cancelAction(sender: NSButton)
  {
    print("Cancel Pressed")
    API.Cancel()
    enableView()
    progressIndicator.stopAnimation(nil)
  }
  
  @IBAction func rememberAction(sender: NSButton)
  {
    updateKeychain()
  }
}

extension LoginViewController: NSTextFieldDelegate
{
  func control(control: NSControl, textView: NSTextView, doCommandBySelector commandSelector: Selector) -> Bool
  {
    if commandSelector == #selector(self.insertNewline)
    {
      self.loginInUser()
      progressIndicator.startAnimation(nil)
      disableView()
      updateKeychain()
     userDefaults.setObject(username, forKey: "username")
      userDefaults.synchronize()
      return true
    }
    return false
  }
}