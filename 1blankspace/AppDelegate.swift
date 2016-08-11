//
//  AppDelegate.swift
//  1blankspace
//
//  Created by Matthew Spear on 03/08/2016.
//  Copyright © 2016 Matthew Spear. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
  func applicationDidFinishLaunching(aNotification: NSNotification)
  {
    // Insert code here to initialize your application
    checkFirstLaunch()
  }

  func applicationWillTerminate(aNotification: NSNotification)
  {
    // Insert code here to tear down your application
    userDefaults.synchronize()
  }
  
  func checkFirstLaunch()
  {
    if userDefaults.boolForKey("hasLaunched")
    {
      print("Launched before")
    }
    else
    {
      print("Launching for the first time...")
      userDefaults.setObject("", forKey: "login")
      userDefaults.setBool(false, forKey: "rememberMe")
      userDefaults.setBool(true, forKey: "hasLaunched")
      userDefaults.synchronize()
    }
  }
}

