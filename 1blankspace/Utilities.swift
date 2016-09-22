//
//  Utilities.swift
//  1blankspace
//
//  Created by Matthew Spear on 12/08/2016.
//  Copyright © 2016 Matthew Spear. All rights reserved.
//

import KeychainAccess

// Useful constants

let bundleIdentifer = Bundle.main.bundleIdentifier!

let keychain = Keychain(service: "uk.co.matthewspear.-blankspace")

let userDefaults = UserDefaults.standard
let userSession = UserSession.sharedInstance
