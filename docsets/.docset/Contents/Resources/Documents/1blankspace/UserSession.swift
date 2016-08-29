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
 - parameter personalGroups:    Personal groups for current session.
 - parameter businessGroups:    Business groups for current session.
 */
public class UserSession
{
  static let sharedInstance = UserSession()
  private init(){}
  
  var sid: String?
  var personalGroups: [Group]?
  var businessGroups: [Group]?
}
