//
//  _blankspaceTests.swift
//  1blankspaceTests
//
//  Created by Matthew Spear on 03/08/2016.
//  Copyright © 2016 Matthew Spear. All rights reserved.
//

import XCTest
import Alamofire
import SwiftyJSON
@testable import _blankspace

class _blankspaceTests: XCTestCase
{
  let login = ""
  let password = ""
  
  override func setUp()
  {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testAPILoginRoundTrip()
  {
    API.login(login, password: password, completion: { result in
      
      }) { error in
        XCTFail("Could not login")
    }
  }
  
  func testAPILoginLogic()
  {
    // Using process login add tests to trigger each case including success, incorrect credentials, malformed json and failure
    
//    let input = jsonFromString("")
    
    
//    let result = Result<Value, Error>()
//    
//    let response = Response(request: nil, response: nil, data: nil, result: result)
//    
//    
//    // Test parsing successful result
//    API.processLogin(response, completion: { result in
//      
//      
//      
//      }, failure: nil)
//    
//    // Test parsing failed result
//    API.processLogin(response, completion: nil) { error in
//      
//      
//    }
  }
  
  
  // test on live server (round trip test)
  // test using API logic (after the response)
  
  /**
   Internal method for setting up test JSON
   */
  func jsonFromString(_ string: String) -> JSON?
  {
    guard let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false) else { return nil }
    return JSON(data: data)
  }
}
