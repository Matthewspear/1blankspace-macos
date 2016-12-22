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
        userDefaults.register(defaults: [
        "login": "",
        "rememberMe": false,
        "SelectedEndpoint": 0
        ])
    }
    
    func applicationWillTerminate(_ aNotification: Notification)
    {
        userDefaults.synchronize()
    }
    

}

