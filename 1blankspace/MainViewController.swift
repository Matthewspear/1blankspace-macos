//
//  MainViewController.swift
//  1blankspace
//
//  Created by Matthew Spear on 04/08/2016.
//  Copyright © 2016 Matthew Spear. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController
{
    @IBOutlet var endpointTableView: NSTableView!
    @IBOutlet var groupTableView: NSTableView!
    @IBOutlet var dataTableView: NSTableView!
    
    @IBOutlet var addButton: NSButton!
    @IBOutlet var editButton: NSButton!
    @IBOutlet var removeButton: NSButton!
    
    @IBOutlet var spinner: NSProgressIndicator!
    
    @IBOutlet var column1: NSTableColumn!
    @IBOutlet var column2: NSTableColumn!
    @IBOutlet var column3: NSTableColumn!
    @IBOutlet var column4: NSTableColumn!
    
    static let reloadNotification = Notification.Name("reload-tables")
    
    var isEnabled: Bool  = false {
        didSet {
            isEnabled ? spinner.stopAnimation(nil) : spinner.startAnimation(nil)
            
            addButton.isEnabled = isEnabled
            editButton.isEnabled = isEnabled
            removeButton.isEnabled = isEnabled
            endpointTableView.isEnabled = isEnabled
            groupTableView.isEnabled = isEnabled
            dataTableView.isEnabled = isEnabled
        }
    }
    
    var selectedEndpoint: Endpoint {
        return endpointTableView.selectedRow == 0 ? .personal : .business
    }
    
    var currentContacts: [Contact] = []
    var currentGroups: [Group] = []
    
    override func viewWillAppear()
    {
        super.viewWillAppear()
        
        let previousEndpoint = userDefaults.integer(forKey: "SelectedEndpoint")
        
        let index = IndexSet(integer: previousEndpoint == 0 ? 0 : 1)
        endpointTableView.selectRowIndexes(index, byExtendingSelection: false)
        
        let endpoint: Endpoint = (previousEndpoint == 0) ? .personal : .business
        
        setColumnTitles(for: endpoint)
        loadData(for: endpoint)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("view did load")
        
        self.spinner.style = .spinningStyle
        self.spinner.isHidden = false
        self.spinner.startAnimation(nil)
        
        endpointTableView.delegate = self
        groupTableView.delegate = self
        dataTableView.delegate = self
        
        endpointTableView.dataSource = self
        groupTableView.dataSource = self
        dataTableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.reloadTables), name: MainViewController.reloadNotification, object: nil)
    }
    
    func loadData(for endpoint: Endpoint)
    {
        isEnabled = false
        
        guard let sid = UserSession.sid else {
            
            displayLoginError()
            isEnabled = false
            return
        }
        
        API.group(endpoint, sid: sid, completion: { groups in
            
            self.currentGroups = groups
            
            switch endpoint
            {
            case .personal:
                API.personal(sid: sid, completion: { contacts in
                    
                    self.currentContacts = contacts
                    notificationCenter.post(name: MainViewController.reloadNotification, object: ["groupTable": true, "dataTable": true])
                    
                }, failure: { error in
                    
                    print(error)
                })
                
            case .business:
                API.business(sid: sid, completion: { contacts in
                    
                    self.currentContacts = contacts
                    notificationCenter.post(name: MainViewController.reloadNotification, object: ["groupTable": true, "dataTable": true])
                    
                }, failure: { error in
                    
                    print(error)
                    
                })
            }
            
        }, failure: { error in
            
            print(error)
        })
    }
    
    func reloadTables(notification: NSNotification)
    {
        print("Reload Tables Notification Recieved")
        
        if let dict = notification.object as? [String: Bool]
        {
            DispatchQueue.main.async {
                
                if dict["groupTable"] == true
                {
                    print("Reloaded Group Table")
                    self.groupTableView.reloadData()
                }
                
                if dict["dataTable"] == true
                {
                    print("Reloaded Data Table")
                    self.dataTableView.reloadData()
                }
                
                self.isEnabled = true
            }
        }
    }
    
    func setColumnTitles(for endpoint: Endpoint)
    {
        switch endpoint
        {
        case .personal:
            column1.title = "First Name"
            column2.title = "Last Name"
        case .business:
            column1.title = "Legal Name"
            column2.title = "Trade Name"
        }
    }
    
    func displayLoginError()
    {
        let userInfo: [AnyHashable: Any] = [
            NSLocalizedDescriptionKey: NSLocalizedString("Login failed or timed out", comment: ""),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString("sid was unavailable", comment: "")]
        
        let loginError = NSError(domain: bundleIdentifer, code: -1, userInfo: userInfo)
        
        self.presentError(loginError)
    }
    
    // MARK: View Controller Actions
    
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
        isEnabled = false
        
        switch sender.selectedRow
        {
        case 0:
            setColumnTitles(for: .personal)
            loadData(for: .personal)
            
        case 1:
            setColumnTitles(for: .business)
            loadData(for: .business)
            
        default: print("Endpoint selection error");
        }
        
        userDefaults.set(sender.selectedRow == 0 ? 0 : 1, forKey: "SelectedEndpoint")
    }
    
    @IBAction func selectGroup(_ sender: NSTableView)
    {
        self.isEnabled = false
        
        let setPersonalContacts: ([PersonalContact]) -> Void = {
            self.currentContacts = $0
            notificationCenter.post(name: MainViewController.reloadNotification, object: ["groupTable": false, "dataTable": true])
        }
        
        let setBusinessContacts: ([BusinessContact]) -> Void = {
            self.currentContacts = $0
            notificationCenter.post(name: MainViewController.reloadNotification, object: ["groupTable": false, "dataTable": true])
        }
        
        let printError: (NSError) -> Void = { error in print(error) }
        
        if let sid = UserSession.sid
        {
            switch (sender.selectedRow, selectedEndpoint)
            {
            case (0, .personal):
                API.personal(sid: sid, completion: setPersonalContacts, failure: printError)
                
            case (1...Int.max, .personal):
                let group = currentGroups[sender.selectedRow - 1]
                API.personal(group.id, search: nil, sid: sid, completion: setPersonalContacts, failure: printError)
                
            case (0, .business):
                API.business(sid: sid, completion: setBusinessContacts, failure: printError)
                
            case (1...Int.max, .business):
                let group = currentGroups[sender.selectedRow - 1]
                API.business(group.id, search: nil, sid: sid, completion: setBusinessContacts, failure: printError)
                
            default: break
            }
        }
    }
}

//MARK: Table View DataSource

extension MainViewController: NSTableViewDataSource
{
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        guard let id = tableView.identifier else { return 0 }
        
        switch id
        {
        case "EndpointTable":
            return 2
        case "GroupTable":
            return 1 + currentGroups.count
        case "DataTable":
            return currentContacts.count
        default:  return 0
        }
    }
}

//MARK: Table View Delegate

extension MainViewController: NSTableViewDelegate
{
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        if let column = tableColumn, let identifier = tableView.identifier
        {
            switch (identifier, row)
            {
            case ("EndpointTable", _):
                let endpointCell = tableView.make(withIdentifier: "EndpointCell", owner: nil) as! NSTableCellView
                endpointCell.imageView?.image = NSImage(named: row == 0 ? NSImageNameUser : NSImageNameUserGroup)
                endpointCell.textField?.stringValue = row == 0 ? "Personal" : "Business"
                return endpointCell
                
            case ("GroupTable", 0):
                let groupCell = tableView.make(withIdentifier: "GroupCell", owner: nil) as! NSTableCellView
                groupCell.textField?.stringValue = "All (\(currentContacts.count))"
                return groupCell
                
            case ("GroupTable", 1...Int.max):
                let groupCell = tableView.make(withIdentifier: "GroupCell", owner: nil) as! NSTableCellView
                groupCell.textField?.stringValue = currentGroups[row - 1].title
                return groupCell
                
            case ("DataTable", _):
                let contactCell = tableView.make(withIdentifier: "DataCell", owner: nil) as! NSTableCellView
                
                if selectedEndpoint == .personal && currentContacts.indices.contains(row)
                {
                    if let person = currentContacts[row] as? PersonalContact
                    {
                        switch column
                        {
                        case tableView.tableColumns[0]:
                            contactCell.textField?.stringValue  = person.firstname
                        case tableView.tableColumns[1]:
                            contactCell.textField?.stringValue  = person.surname
                        case tableView.tableColumns[2]:
                            contactCell.textField?.stringValue  = person.email
                        case tableView.tableColumns[3]:
                            contactCell.textField?.stringValue  = person.mobile
                        default: break
                        }
                    }
                }
                
                if selectedEndpoint == .business && currentContacts.indices.contains(row)
                {
                    if let business = currentContacts[row] as? BusinessContact
                    {
                        switch column
                        {
                        case tableView.tableColumns[0]:
                            contactCell.textField?.stringValue  = business.tradename
                        case tableView.tableColumns[1]:
                            contactCell.textField?.stringValue  = business.legalname
                        case tableView.tableColumns[2]:
                            contactCell.textField?.stringValue  = business.email
                        case tableView.tableColumns[3]:
                            contactCell.textField?.stringValue  = business.phonenumber
                        default: break
                        }
                    }
                }
                return contactCell
                
            default:
                print("Could not display view: \(tableView.identifier) \(column) \(row)")
            }
        }
        else
        {
            print("Could not do it")
        }
        return nil
    }
 }
