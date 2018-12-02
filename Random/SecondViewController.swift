//
//  SecondViewController.swift
//  Random
//
//  Created by Xinyi Wang on 9/10/18.
//  Copyright © 2018 Xinyi Wang. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mask: UIView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var popUpLabel: UILabel!
    
    // The index of selected list (i.e. selected cell)
    private var selectedListIndex = -1
    // The list of lists of itmes to display
    // (the first item in every sublist is the name of that list)
    private var displayList: Array<Array<String>> = []
    // Control for pull to refresh
    private let refreshControl = UIRefreshControl()
    // Name of the new added list
    private var newListName = ""
    // Name of the previous list
    private var prevListName = ""
    // Boolean specifying if the user is adding or editing a list
    private var isAdding = false
    
    // Color Palette
    // #d0fcff, #d0ecff, #d0dcff, #d0ccff, #d0bcff
    // #e2f3ff
    // UIColor(red:0.89, green:0.95, blue:1.00, alpha:1.0)
    // #e2eaff
    // UIColor(red:0.89, green:0.92, blue:1.00, alpha:1.0)
    // #e2e0ff
    // UIColor(red:0.89, green:0.88, blue:1.00, alpha:1.0)
    private var colors: Array<UIColor> = [UIColor(red:0.89, green:0.95, blue:1.00, alpha:1.0), UIColor(red:0.89, green:0.92, blue:1.00, alpha:1.0), UIColor(red:0.89, green:0.88, blue:1.00, alpha:1.0)]
    // Selected Cell Color
    private var selectedCellColor = UIColor(red:1.00, green:1.00, blue:0.61, alpha:1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up the observer to listen to data update
        NotificationCenter.default.addObserver(self, selector: #selector(getDataUpdate), name: NSNotification.Name(rawValue: "update"), object: nil)
        // get new data
        DataModel.sharedInstance.requestData()
        
        // set up textfield
        self.textField.delegate = self
        
        // hide popUpView
        hidePopUp()
        
        // display table view
        tableView.delegate = self
        tableView.dataSource = self
        // uncomment only if changed to custom cell class
        // self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "listcell")
        
        // pull to refresh
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(SecondViewController.refreshData(sender:)), for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // reload table when user switches to this tab
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // remove the observer
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "update"), object: self)
    }

    // For "Add" button
    @IBAction func addNewList(_ sender: UIButton) {
        isAdding = true
        prevListName = ""
        displayPopUp()
    }
    
    // For "Cancel" button in popup
    @IBAction func cancelAdd(_ sender: UIButton) {
        backToListView()
    }
    
    // For "Save" button in popup
    @IBAction func saveChanges(_ sender: UIButton) {
        // change display
        reverseSaveBtn(withAlpha: 0.5)
        if isAdding {
            // add a new entry to displayList
            let newSublist = ["0", newListName]
            displayList.append(newSublist)
            tableView.reloadData()
            
            // save changes to data model
            DataModel.sharedInstance.addData(add: newSublist)
            
        } else if isNew(newListName) {
            // update displayList
            displayList[selectedListIndex][1] = newListName
            let cell : UITableViewCell = tableView.cellForRow(at: [0, selectedListIndex])!
            cell.textLabel?.text = newListName
            
            // save changes to data model
            DataModel.sharedInstance.updateHeader(prev: selectedListIndex, new: -1, toName: newListName)
        }
        backToListView()
    }
    
    // Tableview
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayList.count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.isAdding = false
            self.selectedListIndex = editActionsForRowAt.row
            let cell = tableView.cellForRow(at: editActionsForRowAt)
            self.prevListName = (cell?.textLabel?.text)!
            self.displayPopUp()
        }
        edit.backgroundColor = .lightGray
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            // display a warning for deletion
            let deleteAlert = UIAlertController(title: "Caution", message: "Do you really want to delete this list?", preferredStyle: UIAlertControllerStyle.alert)
            
            // action for real delete
            let deleteAction = UIAlertAction(title: "Yes", style: .default, handler: {
                (action: UIAlertAction!) in
                // TODO: delete the row from local file perminantly
                //
                
                // delete the row from display(screen)
                self.deleteFromDisplay(at: editActionsForRowAt)
                // save changes to data model
                DataModel.sharedInstance.deleteData(deleteAt: editActionsForRowAt.row)
                })
            // add and present alert
            deleteAlert.addAction(deleteAction)
            deleteAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
            }))
            self.present(deleteAlert, animated: true, completion: nil)
            
        }
        delete.backgroundColor = .blue
        
        return [delete, edit]
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.selectedListIndex > -1) {
            // deselect the previous cell
            let prevcell = tableView.cellForRow(at: [0, self.selectedListIndex])
            prevcell!.backgroundColor = self.colors[self.selectedListIndex % 3]
            self.displayList[self.selectedListIndex][0] = "0"
        }
        let prevIndex = self.selectedListIndex
        
        // mark this list as selected
        self.selectedListIndex = indexPath.row
        self.displayList[self.selectedListIndex][0] = "1"
        // get the selected cell
        let cell = tableView.cellForRow(at: indexPath)
        cell!.backgroundColor = selectedCellColor
        
        // save changes to data model
        DataModel.sharedInstance.updateHeader(prev: prevIndex, new: self.selectedListIndex, toName: nil)
        
        // go to main view to display contents of the list
        self.tabBarController?.selectedIndex = 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let celltry = self.tableView.dequeueReusableCell(withIdentifier: "listcell") {
            cell = celltry
        } else {
            cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "listcell")
        }
        
        // configure the cell text
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        let sublist = self.displayList[indexPath.row]
        cell.textLabel?.text = sublist[1]
        cell.detailTextLabel?.text = sublistToString(sublist)
        // configure the cell select style
        cell.selectionStyle = .none
        // update self.selectedListIndex, and cell background
        if (sublist[0] == "1") {
            self.selectedListIndex = indexPath.row
            // mark this list(cell) as selected
            cell.backgroundColor = selectedCellColor
        } else {
            cell.backgroundColor = self.colors[indexPath.row % 3]
        }

        return cell
    }
    
    // Text field editing settings
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        // enable save button if user has entered something
        let newName = textField.text
        if newName != nil && isNew(newName!) {
            reverseSaveBtn(withAlpha: 1.0)
            newListName = newName!
        }
        return false
    }
    
    /* Private Functions */
    
    // Get new data
    @objc private func getDataUpdate() {
        if let data = DataModel.sharedInstance.data {
            displayList = data
        }
    }
    
    // Refresh table entries (for pull to refresh)
    @objc private func refreshData(sender: UIRefreshControl) {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // Delete a cell from display
    private func deleteFromDisplay(at indexPath: IndexPath) {
        // update the cell background
        var cell: UITableViewCell
        for i in indexPath.row + 1..<displayList.count {
            cell = tableView.cellForRow(at: [0, i])!
            cell.backgroundColor = self.colors[(i - 1) % 3]
        }
        // delete from displayList
        displayList.remove(at: indexPath.row)
        // delete the row from table
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    // Return the string representation of sublist of the given list (item from index 1 to end)
    private func sublistToString(_ list: Array<String>) -> String {
        var s: String = ""
        let sublist = list.dropFirst().dropFirst()
        for item in sublist {
            s += "\(item), "
        }
        return String(s.dropLast().dropLast())
    }
    
    // Display the pop up view and dim the main view
    private func displayPopUp() {
        popUpView.isHidden = false
        saveBtn.isEnabled = false
        self.mask.isHidden = false
        if isAdding {
            popUpLabel.text = "New List Name"
            textField.text = ""
            textField.placeholder = "..."
        } else {
            popUpLabel.text = "Edit List Name"
            textField.text = prevListName
        }
    }
    
    // Go back to list view, and adjust display accordingly
    private func backToListView() {
        textField.resignFirstResponder()
        isAdding = false
        hidePopUp()
        prevListName = ""
        newListName = ""
    }
    
    // Hide the pop up view and display the main view
    private func hidePopUp() {
        popUpView.isHidden = true
        self.mask.isHidden = true
    }
    
    // Enable or disable the save button and set its alpha to the given value
    private func reverseSaveBtn(withAlpha alpha: Float) {
        saveBtn.isEnabled = !saveBtn.isEnabled
        saveBtn.alpha = CGFloat(alpha)
        var color = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
        if (alpha == 0.5) {
            color = UIColor(red:0.65, green:0.65, blue:0.65, alpha:1.0)
        }
        saveBtn.setTitleColor(color, for: [])
    }
    
    // Return true if user has entered something new
    private func isNew(_ newName: String) -> Bool {
        return newName != "" && newName != prevListName
    }
}
