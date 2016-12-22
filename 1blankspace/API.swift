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
    case personal
    
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
     - parameter failure:              Closure called when method fails, holding the error.
     */
    
    public static func login(_ username: String, password: String, completion: @escaping (String) -> Void, failure: @escaping (NSError) -> Void)
    {
        let url = "\(baseURL)logon/?method=LOGON"
        
        let params: [String : Any] = [
            "rf": "JSON",
            "Logon": "\(username)",
            "Password": "\(password)"
        ]
        
        let encoding = JSONEncoding.default
        
        request = Alamofire.request(url, method: .post, parameters: params, encoding: encoding, headers: nil).validate().responseJSON { response in
            
            switch response.result
            {
            case .success(let value):
                processLogin(value: value, completion: completion, failure: failure)
                
            case .failure(let error):
                failure(error as NSError)
            }
        }
    }
    
    /**
     Internal method for parsing the login response, extracted to allowing for easier testing.
     */
    internal static func processLogin(value: Any, completion: (String) -> Void, failure: (NSError) -> Void)
    {
        let json = JSON(value)
        
        if let sid = json["sid"].string
        {
            completion(sid)
        }
        else
        {
            // Corrupt, malformed or nil JSON
            let error = generateError()
            failure(error)
        }
    }
    
    
    // MARK: Group Method
    
    /**
     Provides access to personal and business groups on the mydigitalstructure.com platform via the API. Results accessed via completion and failure closures, depending on if the call is successful.
     
     ### Usage Example: ###
     ```
     API.group(.person, sid: "000-k-00aaa00aaaa0a00...", completion: { result in
     
     // Handle result here
     
     }, failure: { error in
     
     // Handle error here
     
     })
     ```
     
     - parameter endpoint:      Selection of either person or business groups.
     - parameter sid:           Session id provided for access to the API available from logon method.
     - parameter completion:    Closure called when method succeeds holding an array of `Group`.
     - parameter failure:       Closure called when method fails holding the error.
     */
    public static func group(_ endpoint: Endpoint, sid: String, completion: @escaping ([Group]) -> Void, failure: @escaping (NSError) -> Void)
    {
        var method: String
        
        switch endpoint
        {
        case .personal: method = "SETUP_CONTACT_PERSON_GROUP_SEARCH"
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
            
            switch response.result
            {
            case .success(let value):
                processGroup(value: value, completion: completion, failure: failure)
                
            case .failure(let error):
                failure(error as NSError)
            }
        })
    }
    
    /**
     Internal method for parsing the group response, extracted to allowing for easier testing.
     */
    internal static func processGroup(value: Any, completion: ([Group]) -> Void, failure: (NSError) -> Void)
    {
        let json = JSON(value)
        
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
            print("Error creating a Contact - Malformed JSON: \(json)")
            // Corrupt, malformed or nil JSON
            let error = generateError()
            failure(error)
        }
    }
    
    /**
     Links a contact to a group on the mydigitalstructure.com platform via the API. Results accessed via completion and failure closures, depending on if the call is successful.
     
     ### Usage Example: ###
     ```
     API.groupLink("1224233", group: "1234", endpoint: .personal, sid: "000-k-00aaa00aaaa0a00...", completion: { result in
     
     // Handle result here
     
     }, failure: { error in
     
     // Handle error here
     
     })
     ```
     
     - parameter contact:       Contact id of the contact to be linked.
     - parameter group:         Group id of the group to be linked to.
     - parameter endpoint:      Selection of either person or business groups.
     - parameter sid:           Session id provided for access to the API available from logon method.
     - parameter completion:    Closure called when method succeeds holding status value.
     - parameter failure:       Closure called when method fails holding the error.
     */
    public static func groupLink(_ contact: String, group: String, endpoint: Endpoint, sid: String, completion: @escaping (Bool) -> Void, failure: @escaping (NSError) -> Void)
    {
        var method: String
        
        switch endpoint
        {
        case .personal: method = "CONTACT_PERSON_GROUP_MANAGE"
        case .business: method = "CONTACT_BUSINESS_GROUP_MANAGE"
        }
        
        let url = "\(baseURL)contact/?method=\(method)"
        
        let body: [String: Any] = [
            "rf": "JSON",
            "sid": "\(sid)",
            "group": group,
            "contactperson": contact,
            "contactbusiness": contact
        ]
        
        let encoding = JSONEncoding.default
        
        request = Alamofire.request(url, method: .post, parameters: body, encoding: encoding, headers: nil).validate().responseJSON(completionHandler: { response in
            
            switch response.result
            {
            case .success(let value):
                processStatus(value: value, completion: completion, failure: failure)
                
            case .failure(let error):
                failure(error as NSError)
            }
        })
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
     
     - parameter group:         Optional group id used to restrict result to a specific group.
     - parameter search:        Optional search query to restrict results to a specific search.
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
            
            switch response.result
            {
            case .success(let value):
                processContact(value: value, completion: completion, failure: failure)
                
            case .failure(let error):
                failure(error as NSError)
            }
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
     
     - parameter group:         Optional group id used to restrict result to a specific group.
     - parameter search:        Optional search query to restrict results to a specific search.
     - parameter completion:    Closure called when method succeeds holding an array of `BusinessContact`.
     - parameter failure:       Closure called when method fails holding the error.
     
     */
    public static func business(_ group: String? = nil, search: String? = nil, sid: String, completion: @escaping ([BusinessContact]) -> Void, failure: @escaping (NSError) -> Void)
    {
        let method = "CONTACT_BUSINESS_SEARCH"
        let url = "\(baseURL)contact/?method=\(method)"
        var filters: [[String : Any]] = []
        
        if let group = group
        {
            filters.append([
                "name": "BusinessGroup",
                "comparison": "TEXT_IS_LIKE",
                "value1": group
                ])
        }
        
        if let search = search
        {
            filters.append([
                "name": "quicksearch",
                "comparison": "TEXT_IS_LIKE",
                "value1": search
                ])
        }
        
        let body: [String : Any] = [
            "rf": "JSON",
            "sid": "\(sid)",
            "advanced": 1,
            "fields": [["name": "legalname"],
                       ["name": "tradename"],
                       ["name": "email"],
                       ["name": "phonenumber"],
                       ["name": "businessgroup"]],
            "summaryFields": [["name": "count contactcount"]],
            "filters": filters,
            "options": ["rows": 100]
        ]
        
        let encoding = JSONEncoding.default
        
        request = Alamofire.request(url, method: .post, parameters: body, encoding: encoding, headers: nil).validate().responseJSON { response in
            
            switch response.result
            {
            case .success(let value):
                processContact(value: value, completion: completion, failure: failure)
                
            case .failure(let error):
                failure(error as NSError)
            }
        }
    }
    
    /**
     A Generic internal method for parsing the contact response, extracted to allowing for easier testing.
     */
    internal static func processContact<T>(value: Any, completion: ([T]) -> Void, failure: (NSError) -> Void)
    {
        let json = JSON(value)
        
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
                    // Corrupt, malformed or nil JSON
                    let error = generateError()
                    failure(error)
                }
            }
            completion(contacts)
        }
        else
        {
            let error: NSError = generateError()
            failure(error)
        }
    }
    
    // MARK: Add Method
    
    /**
     Add contacts to the mydigitalstructure.com platform via the API. Results accessed via completion and failure closures, depending on if the call is successful.
     
     ### Usage Example: ###
     ```
     let sid = "000-k-00aaa00aaaa0a00..."
     let contact = PersonalContact(json: "...")
     
     API.add(contact: contact, endpoint: .personal, sid: sid, completion: { id in
     
     // Handle result here
     
     }, failure: { error in
     
     // Handle error here
     
     })
     ```
     
     - parameter contact:       Contact to be added.
     - parameter endpoint:      Selection of either personal or business contact.
     - parameter sid:           Session id provided for access to the API available from logon method.
     - parameter completion:    Closure called when method succeeds holding the `id` of the created contact.
     - parameter failure:       Closure called when method fails holding the error.
     */
    
    public static func add<T>(contact: T, endpoint: Endpoint, sid: String, completion: @escaping (String) -> Void, failure: @escaping (NSError) -> Void)
    {
        let method = (endpoint == .personal) ? "CONTACT_PERSON_MANAGE" : "CONTACT_BUSINESS_MANAGE"
        let url = "\(baseURL)contact/?method=\(method)"
        
        var body: [String : Any] = [
            "rf": "JSON" as AnyObject,
            "sid": "\(sid)" as AnyObject,
            "advanced": 1 as AnyObject]
        
        if let contact = contact as? PersonalContact
        {
            body["firstname"] = contact.firstname
            body["surname"] = contact.surname
            body["email"] = contact.email
            body["persongroup"] = contact.group
            body["mobile"] = contact.mobile
        }
        
        if let contact = contact as? BusinessContact
        {
            body["legalname"] = contact.legalname
            body["tradename"] = contact.tradename
            body["email"] = contact.email
            body["businessgroup"] = contact.group
            body["phonenumber"] = contact.phonenumber
        }
        
        let encoding = JSONEncoding.default
        
        request = Alamofire.request(url, method: .post, parameters: body, encoding: encoding, headers: nil).validate().responseJSON(completionHandler: { response in
            
            switch response.result
            {
            case .success(let value):
                processAdd(value: value, completion: completion, failure: failure)
                
            case .failure(let error):
                failure(error as NSError)
            }
        })
    }
    
    /**
     Internal method for parsing the response to adding a contact, extracted to allowing for easier testing.
     */
    internal static func processAdd(value: Any, completion: (String) -> Void, failure: @escaping (NSError) -> Void)
    {
        let json = JSON(value)
        
        print(json)
        
        if let id = json["id"].string
        {
            completion(id)
        }
        else
        {
            if let error = json["error"].dictionary, let note = error["errornotes"]?.string
            {
                failure(generateError(title: note))
            }
            else
            {
                failure(generateError())
            }
        }
    }
    
    
    // MARK: Edit Method
    
    /**
     Edit contacts on the mydigitalstructure.com platform via the API. Results accessed via completion and failure closures, depending on if the call is successful.
     
     ### Usage Example: ###
     ```
     let sid = "000-k-00aaa00aaaa0a00..."
     let contact = BusinessContact(json: "...")
     
     API.edit(contact: contact, endpoint: .business, sid: sid, completion: { edited in
     
     // Handle result here
     
     }, failure: { error in
     
     // Handle error here
     
     })
     ```
     
     - parameter contact:       Edited contact, uses id to update contact.
     - parameter endpoint:      Selection of either personal or business contact.
     - parameter sid:           Session id provided for access to the API available from logon method.
     - parameter completion:    Closure called when method succeeds holding status value.
     - parameter failure:       Closure called when method fails holding the error.
     */
    public static func edit<T>(contact: T, endpoint: Endpoint, sid: String, completion: @escaping (Bool) -> Void, failure: @escaping (NSError) -> Void)
    {
        let method = (endpoint == .personal) ? "CONTACT_PERSON_MANAGE" : "CONTACT_BUSINESS_MANAGE"
        let url = "\(baseURL)contact/?method=\(method)"
        
        var body: [String : Any] = [
            "rf": "JSON" as AnyObject,
            "sid": "\(sid)" as AnyObject,
            "advanced": 1 as AnyObject]
        
        if let contact = contact as? PersonalContact
        {
            body["firstname"] = contact.firstname
            body["surname"] = contact.surname
            body["email"] = contact.email
            body["id"] = contact.id
            body["persongroup"] = contact.group
            body["mobile"] = contact.mobile
        }
        
        if let contact = contact as? BusinessContact
        {
            body["legalname"] = contact.legalname
            body["tradename"] = contact.tradename
            body["email"] = contact.email
            body["id"] = contact.id
            body["businessgroup"] = contact.group
            body["phonenumber"] = contact.phonenumber
        }
        
        let encoding = JSONEncoding.default
        
        request = Alamofire.request(url, method: .post, parameters: body, encoding: encoding, headers: nil).validate().responseJSON(completionHandler: { response in
            
            switch response.result
            {
            case .success(let value):
                processStatus(value: value, completion: completion, failure: failure)
                
            case .failure(let error):
                failure(error as NSError)
            }
        })
    }
    
    // MARK: Remove Method

    /**
     Remove a contacts from the mydigitalstructure.com platform via the API. Results accessed via completion and failure closures, depending on if the call is successful.
     
     ### Usage Example: ###
     ```
     let sid = "000-k-00aaa00aaaa0a00..."
     let contact = BusinessContact(json: "...")
     
     API.remove(contact: contact, endpoint: .business, sid: sid, completion: { removed in
     
     // Handle result here
     
     }, failure: { error in
     
     // Handle error here
     
     })
     ```
     
     - parameter contact:       Contact to be removed.
     - parameter endpoint:      Selection of either personal or business contact.
     - parameter sid:           Session id provided for access to the API available from logon method.
     - parameter completion:    Closure called when method succeeds holding status value.
     - parameter failure:       Closure called when method fails holding the error.
     */
    public static func remove<T>(contact: T, endpoint: Endpoint, sid: String, completion: @escaping (Bool) -> Void, failure: @escaping (NSError) -> Void)
    {
        let method = (endpoint == .personal) ? "CONTACT_PERSON_MANAGE" : "CONTACT_BUSINESS_MANAGE"
        let url = "\(baseURL)contact/?method=\(method)"
        
        var body: [String : Any] = [
            "rf": "JSON",
            "sid": "\(sid)",
            "advanced": 1,
            "remove": 1]
        
        if let contact = contact as? Contact
        {
            body["id"] = contact.id
        }
        
        let encoding = JSONEncoding.default
        
        request = Alamofire.request(url, method: .post, parameters: body, encoding: encoding, headers: nil).validate().responseJSON(completionHandler: { response in
            
            switch response.result
            {
            case .success(let value):
                processStatus(value: value, completion: completion, failure: failure)
                
            case .failure(let error):
                failure(error as NSError)
            }
        })
    }
    
    /**
     Internal method for parsing the response status, extracted to allowing for easier testing.
     */
    internal static func processStatus(value: Any, completion: (Bool) -> Void, failure: @escaping (NSError) -> Void)
    {
        let json = JSON(value)
        
        print(json)
        
        if json["status"].stringValue == "OK"
        {
            completion(true)
        }
        else
        {
            if let error = json["error"].dictionary, let note = error["errornotes"]?.string
            {
                failure(generateError(title: note))
            }
            else
            {
                failure(generateError())
            }
        }
    }
    
    // MARK: JSON Error
    
    /**
     Private method for generating errors.
     */
    private static func generateError(title: String = "Could not read in JSON") -> NSError
    {
        let userInfo: [AnyHashable: Any] = [
            NSLocalizedDescriptionKey: NSLocalizedString(title, comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("JSON is corrupt, malformed or nil", comment: "")]
        return NSError(domain: bundleIdentifer, code: -1, userInfo: userInfo)
    }
    
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
