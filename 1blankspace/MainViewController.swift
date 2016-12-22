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
    
    static let reloadTablesNotif = Notification.Name("reload-tables")
    static let reloadDataNotif = Notification.Name("reload-data")
    
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
    
    var contactsInEndpoint: Int {
        get {
            return userDefaults.integer(forKey: "contacts")
        }
        
        set {
            userDefaults.set(newValue, forKey: "contacts")
        }
    }
    
    var currentContacts: [Contact] = []
    var currentGroups: [Group] = []
    
    var selectedEndpoint: Endpoint {
        return endpointTableView.selectedRow == 0 ? .personal : .business
    }
    
    var selectedGroup: Group? {
        
        let index = groupTableView.selectedRow
        
        switch index
        {
        case 0: return Group(title: "All (\(contactsInEndpoint))", id: "")
        case 1...(currentGroups.count + 1): return currentGroups[index - 1]
        default: return nil
        }
    }
    
    var selectedGroupID: String? {
        
        if let groupid = selectedGroup?.id
        {
            return groupid.isEmpty ? nil : groupid
        }
        else
        {
            return nil
        }
    }
    
    var selectedContact: Contact? {
        
        let index = dataTableView.selectedRow
        
        if currentContacts.indices.contains(index)
        {
            return currentContacts[index]
        }
        else
        {
            return nil
        }
    }
    
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
        
        dataTableView.doubleAction = #selector(MainViewController.doubleClickAction)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.reloadTables), name: MainViewController.reloadTablesNotif, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.reloadData), name: MainViewController.reloadDataNotif, object: nil)
    }
    
    func loadData(for endpoint: Endpoint, in group: String? = nil)
    {
        isEnabled = false
        
        guard let sid = UserSession.sid else {
            displayLoginError()
            return
        }
        
        let printError: (Error) -> Void = { print($0) }
        
        API.group(endpoint, sid: sid, completion: { groups in
            
            self.currentGroups = groups
            
            switch endpoint
            {
            case .personal:
                
                API.personal(group, search: nil, sid: sid, completion: { contacts in
                    
                    if group == nil
                    {
                        self.contactsInEndpoint = contacts.count
                    }
                    
                    self.currentContacts = contacts
                    notificationCenter.post(name: MainViewController.reloadTablesNotif, object: ["groupTable": true, "dataTable": true, "keepGroup": true])
                    
                }, failure: printError)
                
            case .business:
                API.business(group, search: nil, sid: sid, completion: { contacts in
                    
                    if group == nil
                    {
                        self.contactsInEndpoint = contacts.count
                    }
                    
                    self.currentContacts = contacts
                    notificationCenter.post(name: MainViewController.reloadTablesNotif, object: ["groupTable": true, "dataTable": true, "keepGroup": true])
                    
                }, failure: printError)
            }
        }, failure: printError)
    }
    
    func reloadData(notification: NSNotification)
    {
        isEnabled = false
        
        if let value = notification.object as? Endpoint
        {
            loadData(for: value, in: selectedGroupID)
        }
    }
    
    func reloadTables(notification: NSNotification)
    {
        print("Reload Tables Notification Recieved")
        
        if let dict = notification.object as? [String: Bool]
        {
            DispatchQueue.main.async {
                
                let selectedGroup = self.groupTableView.selectedRow
                
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
                
                if dict["keepGroup"] == true
                {
                    let indexset = IndexSet(integer: selectedGroup)
                    self.groupTableView.selectRowIndexes(indexset, byExtendingSelection: false)
                }
            }
            
            self.isEnabled = true
            self.editButton.isEnabled = false
            self.removeButton.isEnabled = false
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
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?)
    {
        if let identifer = segue.identifier
        {
            let windowController = segue.destinationController as! NSWindowController
            let panelVC = windowController.contentViewController as! PanelViewController
            
            panelVC.endpoint = selectedEndpoint
            
            switch identifer
            {
            case "toAddView":
                panelVC.mode = .add
                panelVC.groups = [Group(title: "All (\(contactsInEndpoint))", id: "")] + currentGroups
                panelVC.selectedGroup = selectedGroup
                
            case "toEditView":
                panelVC.mode = .edit
                panelVC.groups = [Group(title: "All (\(contactsInEndpoint))", id: "")] + currentGroups
                
                panelVC.selectedGroup = currentGroups.filter { group in
                    group.id == selectedContact?.group
                    }.first
                
                panelVC.column5.isEnabled = false
                panelVC.selectedContact = selectedContact
                
            default:
                break
            }
            
            switch selectedEndpoint
            {
            case .personal:
                panelVC.label1.stringValue = "First Name"
                panelVC.label2.stringValue = "Last Name"
                panelVC.label3.stringValue = "Email"
                panelVC.label4.stringValue = "Phone"
                panelVC.label5.stringValue = "Group"
                
            case .business:
                panelVC.label1.stringValue = "Legal Name"
                panelVC.label2.stringValue = "Trade Name"
                panelVC.label3.stringValue = "Email"
                panelVC.label4.stringValue = "Phone"
                panelVC.label5.stringValue = "Group"
            }
        }
    }
    
    // MARK: View Controller Actions
    
    func doubleClickAction()
    {
        self.performSegue(withIdentifier: "toEditView", sender: self)
    }
    
    @IBAction func addAction(_ sender: NSButton)
    {
        print("Add triggered")
        self.performSegue(withIdentifier: "toAddView", sender: self)
    }
    
    @IBAction func editAction(_ sender: NSButton)
    {
        print("Edit triggered")
        self.performSegue(withIdentifier: "toEditView", sender: self)
    }
    
    @IBAction func removeAction(_ sender: NSButton)
    {
        print("Remove triggered")
        isEnabled = false
        
        guard let sid = UserSession.sid else { return }
        
        API.remove(contact: selectedContact, endpoint: selectedEndpoint, sid: sid, completion: { result in
            
            self.contactsInEndpoint -= 1
            notificationCenter.post(name: MainViewController.reloadDataNotif, object: self.selectedEndpoint)
            
        }, failure: { error in
            
            self.presentError(error)
            self.isEnabled = true
        })
    }
    
    func searchAction(value: String)
    {
        guard let sid = UserSession.sid else { return }
        
        switch selectedEndpoint
        {
        case .personal:
            
            API.personal(nil, search: value, sid: sid, completion: { contacts in
                
                self.currentContacts = contacts
                notificationCenter.post(name: MainViewController.reloadTablesNotif, object: ["groupTable": false, "dataTable": true])
                
            }, failure: { error in
                
                print(error)
                
            })
            
        case .business:
            
            API.business(nil, search: value, sid: sid, completion: { contacts in
                
                self.currentContacts = contacts
                notificationCenter.post(name: MainViewController.reloadTablesNotif, object: ["groupTable": false, "dataTable": true])
                
            }, failure: { error in
                
                print(error)
                
            })
            
        }
        
        print("Searching: \(value)")
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
            notificationCenter.post(name: MainViewController.reloadTablesNotif, object: ["groupTable": false, "dataTable": true])
        }
        
        let setBusinessContacts: ([BusinessContact]) -> Void = {
            self.currentContacts = $0
            notificationCenter.post(name: MainViewController.reloadTablesNotif, object: ["groupTable": false, "dataTable": true])
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
    
    func tableViewSelectionDidChange(_ notification: Notification)
    {
        let tableView = notification.object as! NSTableView
        
        print(tableView.selectedRow)
        
        if tableView.selectedRow == -1
        {
            editButton.isEnabled = false
            removeButton.isEnabled = false
        }
        
        if tableView.isEqual(dataTableView) && tableView.selectedRow != -1
        {
            editButton.isEnabled = true
            removeButton.isEnabled = true
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
                groupCell.textField?.stringValue = "All (\(contactsInEndpoint))"
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
                            contactCell.textField?.stringValue  = business.legalname
                        case tableView.tableColumns[1]:
                            contactCell.textField?.stringValue  = business.tradename
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
