//
//  Utilities.swift
//  1blankspace
//
//  Created by Matthew Spear on 12/08/2016.
//  Copyright © 2016 Matthew Spear. All rights reserved.
//

import KeychainAccess
import Foundation

// Useful constants

let bundleIdentifer = Bundle.main.bundleIdentifier!

let keychain = Keychain(service: "uk.co.matthewspear.-blankspace")

let userDefaults = UserDefaults.standard
let notificationCenter = NotificationCenter.default


// Aliases and functions

typealias SortDescriptor<A> = (A,A) -> Bool

func sortDescriptor<Value, Property>(property: @escaping (Value) -> Property, comparator: @escaping (Property) -> (Property) -> ComparisonResult, order: ComparisonResult) -> SortDescriptor<Value>
{
    return { value1, value2 in
        
        comparator(property(value1))(property(value2)) == order
    }
}
