//
//  PanelViewController.swift
//  1blankspace
//
//  Created by Matthew Spear on 04/08/2016.
//  Copyright © 2016 Matthew Spear. All rights reserved.
//

import Cocoa

enum PanelMode: String
{
    case add = "Add"
    case edit = "Edit"
}

class PanelViewController: NSViewController
{
    // Labels
    @IBOutlet var label1: NSTextField!
    @IBOutlet var label2: NSTextField!
    @IBOutlet var label3: NSTextField!
    @IBOutlet var label4: NSTextField!
    @IBOutlet var label5: NSTextField!
    
    // Columns
    @IBOutlet var column1: NSTextField!
    @IBOutlet var column2: NSTextField!
    @IBOutlet var column3: NSTextField!
    @IBOutlet var column4: NSTextField!
    @IBOutlet var column5: NSPopUpButton!
    
    // Buttons
    @IBOutlet var okButton: NSButton!
    @IBOutlet var cancelButton: NSButton!
    
    var endpoint: Endpoint = .personal
    
    var mode: PanelMode = .add {
        didSet {
            self.view.window?.title = mode.rawValue
        }
    }
    
    var groups: [Group]? {
        didSet {
            column5.removeAllItems()
            
            if let groups = groups
            {
                for group in groups
                {
                    column5.addItem(withTitle: group.title)
                }
            }
        }
    }
    
    var selectedGroup: Group? {
        didSet {
            if let index = groups?.index(where: { $0.id == selectedGroup?.id })
            {
                column5.selectItem(at: index)
            }
        }
    }
    
    var selectedContact: Contact? {
        didSet {
            if let contact = selectedContact as? PersonalContact
            {
                column1.stringValue = contact.firstname
                column2.stringValue = contact.surname
                column3.stringValue = contact.email
                column4.stringValue = contact.mobile
            }
            
            if let contact = selectedContact as? BusinessContact
            {
                column1.stringValue = contact.legalname
                column2.stringValue = contact.tradename
                column3.stringValue = contact.email
                column4.stringValue = contact.phonenumber
            }
        }
    }
    
    var contactsInEndpoint: Int {
        get {
            return userDefaults.integer(forKey: "contacts")
        }
        
        set {
            userDefaults.set(newValue, forKey: "contacts")
        }
    }
    
    var isEnabled: Bool  = false {
        didSet {
            
            column1.isEditable = isEnabled
            column2.isEditable = isEnabled
            column3.isEditable = isEnabled
            column4.isEditable = isEnabled
            column5.isEnabled = isEnabled
            
            okButton.isEnabled = isEnabled
            cancelButton.isEnabled = isEnabled
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        column1.delegate = self
        column2.delegate = self
        column3.delegate = self
        column4.delegate = self
    }
    
    @IBAction func okAction(_ sender: Any)
    {
        isEnabled = false
        
        switch mode
        {
        case .add: addContact()
        case .edit: editContact()
        }
    }
    
    @IBAction func cancelAction(_ sender: NSButton)
    {
        isEnabled = false
        self.view.window?.close()
    }
    
    func addContact()
    {
        guard let sid = UserSession.sid else { return }
        guard let groupid = groups?[column5.indexOfSelectedItem].id else { return }
        
        var contact: Contact
        
        if endpoint == .personal
        {
            contact = PersonalContact(id: "", firstname: column1.stringValue, surname: column2.stringValue, email: column3.stringValue, mobile: column4.stringValue, group: groupid)
        }
        else
        {
            contact = BusinessContact(id: "", tradename: column2.stringValue, legalname: column1.stringValue, email: column3.stringValue, phonenumber: column4.stringValue, group: groupid)
        }
        
        API.add(contact: contact, endpoint: endpoint, sid: sid, completion: { id in
            
            if contact.group.isEmpty
            {
                notificationCenter.post(name: MainViewController.reloadDataNotif, object: self.endpoint)
                self.contactsInEndpoint += 1
                self.view.window?.close()
            }
            else
            {
                API.groupLink(id, group: contact.group, endpoint: self.endpoint, sid: sid, completion: { added in

                        notificationCenter.post(name: MainViewController.reloadDataNotif, object: self.endpoint)
                        self.contactsInEndpoint += 1
                        self.view.window?.close()
                    
                }, failure: {
                    self.presentError($0)
                    self.isEnabled = true
                })
            }
            
        }, failure: {
            self.presentError($0)
            self.isEnabled = true
        })
    }

    func editContact()
    {
        var contact: Contact

        guard let sid = UserSession.sid else { return }
        guard let id = selectedContact?.id else { return }
        guard let groupid = groups?[column5.indexOfSelectedItem].id else { return }

        if endpoint == .personal
        {
            contact = PersonalContact(id: id, firstname: column1.stringValue, surname: column2.stringValue, email: column3.stringValue, mobile: column4.stringValue, group: groupid)
        }
        else
        {
            contact = BusinessContact(id: id, tradename: column2.stringValue, legalname: column1.stringValue, email: column3.stringValue, phonenumber: column4.stringValue, group: groupid)
        }

        API.edit(contact: contact, endpoint: endpoint, sid: sid, completion: { edited in

                notificationCenter.post(name: MainViewController.reloadDataNotif, object: self.endpoint)
                self.view.window?.close()
                
        }, failure: {
            self.presentError($0)
        })
    }
}

extension PanelViewController: NSTextFieldDelegate
{
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool
    {
        if commandSelector == #selector(self.insertNewline)
        {
            print("Enter Pressed")
            okAction(self)
            
            return true
        }
        return false
    }
}
