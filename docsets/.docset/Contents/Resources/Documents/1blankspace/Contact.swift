//
//  Contact.swift
//  1blankspace
//
//  Created by Matthew Spear on 29/08/2016.
//  Copyright © 2016 Matthew Spear. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 PersonalContact object created from the `API`.
 
 Can be initialised with parameters for testing or via a JSON object.
 
 - parameter id:          ID of the contact.
 - parameter firstname:   Firstname of the contact.
 - parameter surname:     Surname of the contact.
 - parameter email:       Email address of the contact.
 - parameter mobile:      Mobile number of the contact.
 - parameter group:       Group of the contact.
 */
public struct PersonalContact
{
  let id: String
  let firstname: String
  let surname: String
  let email: String
  let mobile: String
  let group: String
}

extension PersonalContact
{
  init?(json: JSON)
  {
    guard let id = json["id"].string, firstname = json["firstname"].string, surname = json["surname"].string, email = json["email"].string, mobile = json["mobile"].string,
      group = json["persongroup"].string else { return nil }
    self.init(id: id,firstname: firstname, surname: surname, email: email, mobile: mobile, group: group)
  }
}

/**
 BusinessContact object created from the `API`.
 
 Can be initialised with parameters for testing or via a JSON object.
 
 - parameter id:            ID of the contact.
 - parameter tradename:     Tradename of the contact.
 - parameter legalname:     Legalname of the contact.
 - parameter email:         Email address of the contact.
 - parameter phonenumber:   Phone number of the contact.
 - parameter group:         Group of the contact.
 */
public struct BusinessContact
{
  let id: String
  let tradename: String
  let legalname: String
  let email: String
  let phonenumber: String
  let group: String
}

extension BusinessContact
{
  init?(json: JSON)
  {
    guard let id = json["id"].string, legalname = json["legalname"].string, tradename = json["tradename"].string, email = json["email"].string, phonenumber = json["phonenumber"].string,
      group = json["businessgroup"].string else { return nil }
    self.init(id: id, tradename: tradename, legalname: legalname, email: email, phonenumber: phonenumber, group: group)
  }
}