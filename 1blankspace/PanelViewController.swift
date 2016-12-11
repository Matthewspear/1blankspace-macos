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

    var editContact: Contact? {
        didSet {
            if let contact = editContact as? PersonalContact
            {
                column1.stringValue = contact.firstname
                column2.stringValue = contact.surname
                column3.stringValue = contact.email
                column4.stringValue = contact.mobile
            }
            
            if let contact = editContact as? BusinessContact
            {
                column1.stringValue = contact.legalname
                column2.stringValue = contact.tradename
                column3.stringValue = contact.email
                column4.stringValue = contact.phonenumber
            }
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
    
    @IBAction func okAction(_ sender: NSButton)
    {
        print("OK triggered")
        
        print(column1.stringValue)
        print(column2.stringValue)
        print(column3.stringValue)
        print(column4.stringValue)
        print(column5.indexOfSelectedItem)
        
        self.view.window?.close()
    }
    
    @IBAction func cancelAction(_ sender: NSButton)
    {
        print("Cancel triggered")
        self.view.window?.close()
    }
}

extension PanelViewController: NSTextFieldDelegate
{
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool
    {
        if commandSelector == #selector(self.insertNewline)
        {
            print("Enter Pressed")
            return true
        }
        return false
    }
}
