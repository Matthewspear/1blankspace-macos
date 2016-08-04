//
//  MainViewController.swift
//  1blankspace
//
//  Created by Matthew Spear on 04/08/2016.
//  Copyright © 2016 Matthew Spear. All rights reserved.
//

import Cocoa

//TODO: Add Autolayout for Storyboard

class MainViewController: NSViewController
{
  @IBOutlet var dataTableView: NSTableView!
  @IBOutlet var endpointTableView: NSTableView!
  @IBOutlet var groupTableView: NSTableView!
  
  @IBOutlet var addButton: NSButton!
  @IBOutlet var editButton: NSButton!
  @IBOutlet var removeButton: NSButton!
  
  @IBOutlet var spinner: NSProgressIndicator!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  
  @IBAction func addAction(sender: NSButton)
  {
    print("Add triggered")
  }
  
  @IBAction func editAction(sender: NSButton)
  {
    print("Edit triggered")
  }
  
  @IBAction func removeAction(sender: NSButton)
  {
    print("Remove triggered")
  }
  
  @IBAction func selectEndpoint(sender: NSTableView)
  {
    print("Select Endpoint triggered")
  }
  
  @IBAction func selectGroup(sender: NSTableView)
  {
    print("Select Group triggered")
  }
}
