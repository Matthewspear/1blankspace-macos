//
//  Group.swift
//  1blankspace
//
//  Created by Matthew Spear on 28/08/2016.
//  Copyright © 2016 Matthew Spear. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 Group object created from the `API`.
 
 Can be initialised with parameters for testing or via a JSON object.
 
 - parameter title:   Title of the group.
 - parameter id:      ID of the group.
 */
public struct Group
{
    let title: String
    let id: String
}

extension Group
{
    init?(json: JSON)
    {
        guard let title = json["title"].string, let id = json["id"].string else { return nil }
        self.init(title: title, id: id)
    }
}
