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
  func applicationDidFinishLaunching(_ aNotification: Notification)
  {
    // Insert code here to initialize your application
    checkFirstLaunch()
  }

  func applicationWillTerminate(_ aNotification: Notification)
  {
    // Insert code here to tear down your application
    userDefaults.synchronize()
  }
  
  func checkFirstLaunch()
  {
    if userDefaults.bool(forKey: "hasLaunched")
    {
      print("Launched before")
    }
    else
    {
      print("Launching for the first time...")
      userDefaults.set("", forKey: "login")
      userDefaults.set(false, forKey: "rememberMe")
      userDefaults.set(0, forKey: "SelectedEndpoint")
      userDefaults.set(true, forKey: "hasLaunched")
      userDefaults.synchronize()
    }
  }
}

