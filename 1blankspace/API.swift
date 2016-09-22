//
//  APIRequest.swift
//  1blankspace
//
//  Created by Matthew Spear on 04/08/2016.
//  Copyright © 2016 Matthew Spear. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/// Group Endpoints
public enum Endpoint
{
    /// Access to personal group / contacts.
    case person
    
    /// Access to business group / contacts.
    case business
}

/// API with methods for accessing the mydigitalstructure.com platform.
public struct API
{
    private static let baseURL = "https://secure.mydigitalspacelive.com/rpc/"
    private static var request: Request?
    
    /// If the API is currently active issuing a request
    public static var isActive: Bool {
        
        return request != nil
    }
    
    // MARK: Login Method
    
    /**
     Provides login to the mydigitalstructure.com platform via the API. Results accessed via both completion and failure closures, depending on if the call is successful.
     
     ### Usage Example: ###
     ```
     API.login("someuser@email.com", password: "theirPassword", completion: { result in
     
     // Handle result here
     
     }) { error in
     
     // Handle error here
     
     }
     ```
     
     - parameter username, password:   Login used to access mydigitalstructure.com.
     - parameter completion:           Closure called when method succeeds holding the session id (sid).
     - parameter failure:              Closure called when method fails holding the error.
     */
    
    public static func login(_ username: String, password: String, completion: @escaping (String) -> Void, failure: @escaping (NSError) -> Void)
    {
        let url = "\(baseURL)logon/?method=LOGON"
        
        let params: [String : AnyObject] = [
            "rf": "JSON" as AnyObject,
            "Logon": "\(username)" as AnyObject,
            "Password": "\(password)" as AnyObject
        ]
        
        let encoding = JSONEncoding.default
        
        request = Alamofire.request(url, method: .post, parameters: params, encoding: encoding, headers: nil).validate().responseJSON { response in
            
            self.processLogin(response, completion: completion, failure: failure)
        }
        
        //    request = Alamofire.request(.POST, url, parameters: params, encoding: encoding, headers: nil).validate().responseJSON { response in
        //
        //      self.processLogin(response, completion: completion, failure: failure)
        //    }
    }
    
    /**
     Internal method for parsing the login response, extracted to allowing for easier testing.
     */
    internal static func processLogin(_ response: DataResponse<Any>, completion: (String) -> Void, failure: (NSError) -> Void)
    {
        switch response.result
        {
        case .success:
            
            let json = JSON(response.result.value!)
            
            if let sid = json["sid"].string
            {
                completion(sid)
            }
            else
            {
                // Corrupt, malformed or nil JSON
                let userInfo: [AnyHashable: Any] = [
                    NSLocalizedDescriptionKey: NSLocalizedString("Could not read in JSON", comment: ""),
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString("JSON is corrupt, malformed or nil", comment: "")]
                let error = NSError(domain: bundleIdentifer, code: -1, userInfo: userInfo)
                print(error)
                failure(error)
            }
            
        case .failure(let error):
            failure(error as NSError)
        }
    }
    
    
    // MARK: Group Method
    
    /**
     Provides access to personal and business groups on the mydigitalstructure.com platform via the API. Results accessed via completion and failure closures, depending on if the call is successful.
     
     ### Usage Example: ###
     ```
     API.group(.Person, sid: "000-k-00aaa00aaaa0a00...", completion: { result in
     
     // Handle result here
     
     }, failure: { error in
     
     // Handle error here
     
     })
     ```
     
     - parameter endpoint:      Selection of either personal or business groups.
     - parameter sid:           Session id provided for access to the API available from logon method.
     - parameter completion:    Closure called when method succeeds holding an array of `Group`.
     - parameter failure:       Closure called when method fails holding the error.
     
     */
    public static func group(_ endpoint: Endpoint, sid: String, completion: @escaping ([Group]) -> Void, failure: @escaping (NSError) -> Void)
    {
        var method: String
        
        switch endpoint
        {
        case .person: method = "SETUP_CONTACT_PERSON_GROUP_SEARCH"
        case .business: method = "SETUP_CONTACT_BUSINESS_GROUP_SEARCH"
        }
        
        let url = "\(baseURL)setup/?method=\(method)"
        
        let body: [String: Any] = [
            "rf": "JSON",
            "sid": "\(sid)",
            "fields": [["name": "Id"], ["name": "Title"], ["name": "Reference"]],
            "summaryFields": [["name": "count contactcount"]],
            "filters": [],
            "options": ["rows": 100]
        ]
        
        let encoding = JSONEncoding.default
        
        request = Alamofire.request(url, method: .post, parameters: body, encoding: encoding, headers: nil).validate().responseJSON(completionHandler: { response in
            
            self.processGroup(response: response, completion: completion, failure: failure)
            
        })
    }
    
    /**
     Internal method for parsing the group response, extracted to allowing for easier testing.
     */
    internal static func processGroup(response: DataResponse<Any>, completion: ([Group]) -> Void, failure: (NSError) -> Void)
    {
        switch response.result
        {
        case .success:
            
            let json = JSON(response.result.value!)
            
            if let data = json["data"].dictionary, let rows = data["rows"]?.array
            {
                var groups: [Group] = []
                
                for json in rows
                {
                    if let group = Group(json: json)
                    {
                        groups.append(group)
                    }
                    else
                    {
                        print("Error creating a Group - Malformed JSON: \(json)")
                    }
                }
                completion(groups)
            }
            else
            {
                // Corrupt, malformed or nil JSON
                let userInfo: [String: Any] = [
                    NSLocalizedDescriptionKey: NSLocalizedString("Could not read in JSON", comment: ""),
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString("JSON is corrupt, malformed or nil", comment: "")]
                let error = NSError(domain: bundleIdentifer, code: -1, userInfo: userInfo)
                print(error)
                
                failure(error)
            }
            
        case .failure(let error):
            failure(error as NSError)
        }
    }
    
    
    // MARK: Personal Contact Method
    
    /**
     Provides access to personal contacts on the mydigitalstructure.com platform via the API. Results accessed via completion and failure closures, depending on if the call is successful.
     
     - Note: Both group and search are optional and can be set to `nil` to return the full list of contacts.
     
     ### Usage Example: ###
     ```
     let sid = "000-k-00aaa00aaaa0a00..."
     
     API.personal("6978", search: "Steve", sid: sid, completion: { result in
     
     // Handle result here
     
     }, failure: { error in
     
     // Handle error here
     
     })
     ```
     
     - parameter group:         Group id used to restrict result to a specific group
     - parameter search:        Search string to restrict results to a specific search
     - parameter completion:    Closure called when method succeeds holding an array of `PersonalContact`.
     - parameter failure:       Closure called when method fails holding the error.
     
     */
    public static func personal(_ group: String? = nil, search: String? = nil, sid: String, completion: @escaping ([PersonalContact]) -> Void, failure: @escaping (NSError) -> Void)
    {
        let method = "CONTACT_PERSON_SEARCH"
        let url = "\(baseURL)contact/?method=\(method)"
        var filters: [[String : AnyObject]] = []
        
        if let group = group
        {
            filters.append([
                "name": "PersonGroup" as AnyObject,
                "comparison": "TEXT_IS_LIKE" as AnyObject,
                "value1": group as AnyObject
                ])
        }
        
        if let search = search
        {
            filters.append([
                "name": "quicksearch" as AnyObject,
                "comparison": "TEXT_IS_LIKE" as AnyObject,
                "value1": search as AnyObject
                ])
        }
        
        let body: [String : Any] = [
            "rf": "JSON" as AnyObject,
            "sid": "\(sid)" as AnyObject,
            "advanced": 1 as AnyObject,
            "fields": [
                ["name": "firstname"],
                ["name": "surname"],
                ["name": "email"],
                ["name": "mobile"],
                ["name": "persongroup"]],
            "summaryFields": [["name": "count contactcount"]],
            "filters": filters,
            "options": ["rows": 100]
        ]
        
        let encoding = JSONEncoding.default
        
        request = Alamofire.request(url, method: .post, parameters: body, encoding: encoding, headers: nil).validate().responseJSON(completionHandler: { response in
            
            self.processContact(response, completion: completion, failure: failure)
        })
    }
    
    
    // MARK: Business Contact Method
    
    /**
     Provides access to business contacts on the mydigitalstructure.com platform via the API. Results accessed via completion and failure closures, depending on if the call is successful.
     
     - Note: Both group and search are optional and can be set to `nil` to return the full list of contacts.
     
     ### Usage Example: ###
     ```
     let sid = "000-k-00aaa00aaaa0a00..."
     
     API.business("6932", search: "Rachael", sid: sid, completion: { result in
     
     // Handle result here
     
     }, failure: { error in
     
     // Handle error here
     
     })
     ```
     
     - parameter group:         Group id used to restrict result to a specific group
     - parameter search:        Search string to restrict results to a specific search
     - parameter completion:    Closure called when method succeeds holding an array of `BusinessContact`.
     - parameter failure:       Closure called when method fails holding the error.
     
     */
    public static func business(_ group: String? = nil, search: String? = nil, sid: String, completion: @escaping ([BusinessContact]) -> Void, failure: @escaping (NSError) -> Void)
    {
        let method = "CONTACT_BUSINESS_SEARCH"
        let url = "\(baseURL)contact/?method=\(method)"
        var filters: [[String : AnyObject]] = []
        
        if let group = group
        {
            filters.append([
                "name": "BusinessGroup" as AnyObject,
                "comparison": "TEXT_IS_LIKE" as AnyObject,
                "value1": group as AnyObject
                ])
        }
        
        if let search = search
        {
            filters.append([
                "name": "quicksearch" as AnyObject,
                "comparison": "TEXT_IS_LIKE" as AnyObject,
                "value1": search as AnyObject
                ])
        }
        
        let body: [String : Any] = [
            "rf": "JSON",
            "sid": "\(sid)",
            "advanced": 1,
            "fields": [["name": "Legalname"],
                       ["name": "Tradename"],
                       ["name": "Email"],
                       ["name": "PhoneNumber"],
                       ["name": "BusinessGroup"]],
            "summaryFields": [["name": "count contactcount"]],
            "filters": filters,
            "options": ["rows": 100]
        ]
        
        let encoding = JSONEncoding.default
        
        request = Alamofire.request(url, method: .post, parameters: body, encoding: encoding, headers: nil).validate().responseJSON { response in
            
            self.processContact(response, completion: completion, failure: failure)
        }
    }
    
    
    /**
     A Generic internal method for parsing the contact response, extracted to allowing for easier testing.
     */
    internal static func processContact<T>(_ response: DataResponse<Any>, completion: ([T]) -> Void, failure: (NSError) -> Void)
    {
        switch response.result
        {
        case .success:
            
            let json = JSON(response.result.value!)
            
            if let data = json["data"].dictionary, let rows = data["rows"]?.array
            {
                var contacts: [T] = []
                
                for json in rows
                {
                    if let contact = PersonalContact(json: json) as? T
                    {
                        contacts.append(contact)
                    }
                    else if let contact = BusinessContact(json: json) as? T
                    {
                        contacts.append(contact)
                    }
                    else
                    {
                        print("Error creating a Contact - Malformed JSON: \(json)")
                    }
                }
                completion(contacts)
            }
            else
            {
                // Corrupt, malformed or nil JSON
                let userInfo: [AnyHashable: Any] = [
                    NSLocalizedDescriptionKey: NSLocalizedString("Could not read in JSON", comment: ""),
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString("JSON is corrupt, malformed or nil", comment: "")]
                let error = NSError(domain: bundleIdentifer, code: -1, userInfo: userInfo)
                print(error)
                failure(error)
            }
            
        case .failure(let error):
            failure(error as NSError)
        }
    }
    
    
    // MARK: Edit Method
    
    
    // MARK: Cancel Method
    
    /**
     Cancel current API request
     */
    static func cancel()
    {
        request?.cancel()
        request = nil
    }
}

