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
    print("view did load")
    
    endpointTableView.delegate = self
    groupTableView.delegate = self
    dataTableView.delegate = self
    
    endpointTableView.dataSource = self
    groupTableView.dataSource = self
    dataTableView.dataSource = self
    
    //    NSImage(named: NSImageNameUser)
    //    NSImage(named: NSImageNameUserGroup)
    
    if let sid = userSession.sid
    {
      API.personal(sid: sid, completion: { result in
        
        print("PERSONAL")
        
        for contact in result
        {
          print("\(contact.firstname)")
        }
        
        }, failure: { (error) in
         print(error)
      })
      
      API.business(sid: sid, completion: { result in
        
        print("BUSINESS")
        
        for contact in result
        {
          print("\(contact.legalname)")
        }
        
        }, failure: { (error) in
          print(error)
      })
    }
  }
  
  @IBAction func addAction(_ sender: NSButton)
  {
    print("Add triggered")
  }
  
  @IBAction func editAction(_ sender: NSButton)
  {
    print("Edit triggered")
  }
  
  @IBAction func removeAction(_ sender: NSButton)
  {
    print("Remove triggered")
  }
  
  @IBAction func selectEndpoint(_ sender: NSTableView)
  {
    print("Select Endpoint triggered")
  }
  
  @IBAction func selectGroup(_ sender: NSTableView)
  {
    print("Select Group triggered")
  }
}

extension MainViewController: NSTableViewDataSource
{
  func numberOfRows(in tableView: NSTableView) -> Int
  {
    if let id = tableView.identifier
    {
      switch id
      {
      case "endpointTable": return 2
      case "groupTable": return 0
      case "dataTable": return 0
      default: return 0
      }
    }
    else
    {
      return 0
    }
  }
}

extension MainViewController: NSTableViewDelegate
{
  func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView?
  {
    return NSTableRowView()
  }
}
