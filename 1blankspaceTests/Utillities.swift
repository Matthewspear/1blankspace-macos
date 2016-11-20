//
//  Utillities.swift
//  1blankspace
//
//  Created by Matthew Spear on 20/11/2016.
//  Copyright © 2016 Matthew Spear. All rights reserved.
//

import Foundation

func ==(lhs: Group, rhs: Group) -> Bool
{
    return lhs.id == rhs.id && lhs.title == rhs.title
}

func ==(lhs: PersonalContact, rhs: PersonalContact) -> Bool
{
    return lhs.firstname == lhs.firstname && lhs.surname == rhs.surname && lhs.mobile == rhs.mobile && lhs.email == rhs.email && lhs.group == rhs.group && lhs.id == rhs.id
}

func ==(lhs: BusinessContact, rhs: BusinessContact) -> Bool
{
    return lhs.email == rhs.email && lhs.group == rhs.group && lhs.id == rhs.id && lhs.legalname == rhs.legalname && lhs.phonenumber == rhs.phonenumber && lhs.tradename == rhs.tradename
}
