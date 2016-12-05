//
//  UserSession.swift
//  1blankspace
//
//  Created by Matthew Spear on 29/08/2016.
//  Copyright © 2016 Matthew Spear. All rights reserved.
//

import Foundation

/**
 Singleton used for storing / accessing variable for user session.
 
 - parameter sid:               Session id for current session.
 */
public class UserSession
{
    private init(){}
    
    static var sid: String?
    static var businessContacts: [BusinessContact]?
    static var personalContacts: [PersonalContact]?
}
