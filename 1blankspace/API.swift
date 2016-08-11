//
//  APIRequest.swift
//  1blankspace
//
//  Created by Matthew Spear on 04/08/2016.
//  Copyright © 2016 Matthew Spear. All rights reserved.
//

import Foundation
import Alamofire

enum APIEndpoint: Int
{
  case Person = 0
  case Business = 1
}

enum APIRequestType
{
  case GetGroup         // Getting list of groups for current endpoint
  case GetGroupData     // Getting a list of data for a selected group
  case AddData          // Adding row in a list
  case RemoveData       // Removing data from a list
  case EditData         // Editing row in a list
  case AddToGroup       // Adding a row to a specified group
  case Unknown          // Error
}

public struct API
{
  private static let baseURL = "https://secure.mydigitalspacelive.com/rpc/"
  private static var request: Request?
  
  static func login(username: String, password: String, completion: (result: String) -> Void, failure: (error: String) -> Void)
  {
    let url = "\(baseURL)logon/?method=LOGON"
    
    let params: [String : AnyObject] = [
      "Logon": "\(username)",
      "Password": "\(password)"
    ]
    
    let encoding = ParameterEncoding.JSON
    
    request = Alamofire.request(.POST, url, parameters: params, encoding: encoding, headers: nil).validate().responseJSON { response in
      
      self.processLogin(response, completion: completion, failure: failure)
    }
  }
  
  // TODO: Create error code system
  // TODO: Add tests for internal logic components
  internal static func processLogin(response: Response<AnyObject, NSError>, completion: (result: String) -> Void, failure: (error: String) -> Void)
  {
    switch response.result
    {
    case .Success:
      if let JSON = response.result.value, let sid = JSON["sid"] as? String
      {
        completion(result: sid)
      }
      else
      {
        // Corrupt or malformed JSON and failure
        failure(error: "FAIL_ERROR")
      }
      
    case .Failure(let error):
      
      print(error)
      failure(error: "NETWORK_ERROR")
    }
  }
  
  static func Cancel()
  {
    request?.cancel()
    request = nil
  }
}

