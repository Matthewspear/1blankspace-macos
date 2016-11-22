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
    let failure: (NSError) -> () = { _ in XCTFail() }
    
    
    // MARK: Support Functions
    
    func loadJSON(forResource filename: String, withExtension ext: String = "json") -> Any?
    {
        let bundle = Bundle(for: type(of: self))
        if let fileURL = bundle.url(forResource: filename, withExtension: ext)
        {
            do {
                let jsonData = NSData(contentsOf: fileURL)
                let value = try JSONSerialization.jsonObject(with: jsonData as! Data, options: .allowFragments)
                
                return value
            }
            catch let error as NSError
            {
                print(error)
            }
        }
        return nil
    }
    
    // MARK: Initialiser Tests
    
    func testGroup()
    {
        guard let value = loadJSON(forResource: "group") else { XCTFail(); return }
        
        let json = JSON(value)
        let group = Group(json: json)
        
        XCTAssertNotNil(group)
        XCTAssertEqual(group?.id, "1234")
        XCTAssertEqual(group?.title, "Friends")
    }
    
    func testPersonalContact()
    {
        guard let value = loadJSON(forResource: "personalContact") else { XCTFail(); return }
        
        let json = JSON(value)
        let person = PersonalContact(json: json)
        
        XCTAssertNotNil(person)
        XCTAssertEqual(person?.firstname, "John")
        XCTAssertEqual(person?.surname, "Smith")
        XCTAssertEqual(person?.mobile, "0410 123 456")
        XCTAssertEqual(person?.group, "")
        XCTAssertEqual(person?.id, "1000446786")
    }
    
    func testBusinessContact()
    {
        guard let value = loadJSON(forResource: "businessContact") else { XCTFail(); return }
        
        let json = JSON(value)
        let business = BusinessContact(json: json)
        
        XCTAssertNotNil(business)
        XCTAssertEqual(business?.tradename, "onDemand Testing")
        XCTAssertEqual(business?.legalname, "Blankspace Corp")
        XCTAssertEqual(business?.email, "test@company.co")
        XCTAssertEqual(business?.phonenumber, "02 1234 6749")
        XCTAssertEqual(business?.group, "3394")
        XCTAssertEqual(business?.id, "1258093")
    }
    
    
    // MARK: API Tests
    
    func testLogin()
    {
        guard let value = loadJSON(forResource: "login") else { XCTFail(); return }
        
        API.processLogin(value: value, completion: { sid in
            
            XCTAssertEqual(sid, "345389155-k-8cb1ceaaa321fb257cb61ed659c55cc7")
            
        }, failure: failure)
    }
    
    func testPersonalGroup()
    {
        guard let value = loadJSON(forResource: "personalGroups") else { XCTFail(); return }
        
        let customer = Group(title: "Customer", id: "6977")
        let supplier = Group(title: "Supplier", id: "6978")
        let friends = Group(title: "Friends", id: "7137")
        
        API.processGroup(value: value, completion: { groups in
            
            XCTAssertTrue(groups.contains { $0 == customer })
            XCTAssertTrue(groups.contains { $0 == supplier })
            XCTAssertTrue(groups.contains { $0 == friends })
            XCTAssertEqual(groups.count, 3)
            
        }, failure: failure)
    }
    
    func testBusinessGroup()
    {
        guard let value = loadJSON(forResource: "businessGroups") else { XCTFail(); return }
        
        let financier = Group(title: "Financier", id: "3394")
        
        API.processGroup(value: value, completion: { groups in
            
            XCTAssertTrue(groups.contains { $0 == financier })
            XCTAssertEqual(groups.count, 1)
            
        }, failure: failure)
    }
    
    func testPersonalContacts()
    {
        guard let value = loadJSON(forResource: "personalContacts") else { XCTFail(); return }
        
        let johnSmith = PersonalContact(id: "1000446786", firstname: "John", surname: "Smith", email: "test@email.com", mobile: "0410 123 456", group: "")
        
        let completion: ([PersonalContact]) -> Void = { contacts in
            
            XCTAssertTrue(contacts.contains { $0 == johnSmith })
            XCTAssertEqual(contacts.count, 5)
        }
        
        API.processContact(value: value, completion: completion, failure: failure )
    }
    
    func testBusinessContacts()
    {
        guard let value = loadJSON(forResource: "businessContacts") else { XCTFail(); return }
        
        let testCompany = BusinessContact(id: "1258093", tradename: "onDemand Testing", legalname: "Blankspace Corp", email: "test@company.co", phonenumber: "02 1234 6749", group: "3394")
        
        let completion: ([BusinessContact]) -> Void = { contacts in
            
            XCTAssertTrue(contacts.contains { $0 == testCompany })
            XCTAssertEqual(contacts.count, 6)
        }
        
        API.processContact(value: value, completion: completion, failure: failure )
    }
}



