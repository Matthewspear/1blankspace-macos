//
//  PanelViewController.swift
//  1blankspace
//
//  Created by Matthew Spear on 04/08/2016.
//  Copyright © 2016 Matthew Spear. All rights reserved.
//

import Cocoa

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

  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  @IBAction func okAction(_ sender: NSButton)
  {
    print("OK triggered")
  }
  
  @IBAction func cancelAction(_ sender: NSButton)
  {
    print("Cancel triggered")
  }
}
