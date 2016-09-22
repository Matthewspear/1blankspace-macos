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
    
    rememberButton.state = userDefaults.bool(forKey: "rememberMe") ? 1 : 0
    
    if userDefaults.bool(forKey: "rememberMe")
    {
      loginTextField.stringValue = userDefaults.string(forKey: "username") ?? ""
      passwordTextField.stringValue = keychain[username] ?? ""
    }
  }
  
  func loginInUser()
  {
    API.login(username, password: password, completion: { result in
      
      userSession.sid = result
      self.enableView()
      self.progressIndicator.stopAnimation(self)
      self.performSegue(withIdentifier: "toMainView", sender: self)
      self.view.window?.close()
      
    }) { error in
      
      self.presentError(error)
      self.errorTextField.isHidden = false
      self.enableView()
      self.progressIndicator.stopAnimation(self)
    }
  }
  
  func disableView()
  {
    loginTextField.isEnabled = false
    passwordTextField.isEnabled = false
    rememberButton.isEnabled = false
    loginButton.isEnabled = false
    
    errorTextField.isHidden = true
  }
  
  func enableView()
  {
    loginTextField.isEnabled = true
    passwordTextField.isEnabled = true
    rememberButton.isEnabled = true
    loginButton.isEnabled = true
  }
  
  func updateKeychain()
  {
    switch rememberButton.state
    {
    case 0:
      // Deleting password
      keychain[username] = nil
      userDefaults.set(false, forKey: "rememberMe")
      
    case 1:
      // Storing password
      keychain[username] = password
      userDefaults.set(true, forKey: "rememberMe")
      
    default: break
    }
  }
  
  @IBAction func loginAction(_ sender: NSButton)
  {
    loginInUser()
    progressIndicator.startAnimation(nil)
    disableView()
    
    updateKeychain()
    userDefaults.set(username, forKey: "username")
    userDefaults.synchronize()
  }
  
  @IBAction func cancelAction(_ sender: NSButton)
  {
    if API.isActive
    {
      API.cancel()
      enableView()
      progressIndicator.stopAnimation(nil)
    }
    else
    {
      NSApplication.shared().terminate(self)
    }
  }
  
  @IBAction func rememberAction(_ sender: NSButton)
  {
    updateKeychain()
  }
}

extension LoginViewController: NSTextFieldDelegate
{
  func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool
  {
    if commandSelector == #selector(self.insertNewline)
    {
      self.loginInUser()
      progressIndicator.startAnimation(nil)
      disableView()
      updateKeychain()
      userDefaults.set(username, forKey: "username")
      userDefaults.synchronize()
      return true
    }
    return false
  }
}
