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
    
    // The list of lists of itmes to display
    // (the first item in every sublist is the name of that list)
    private var displayList: Array<Array<String>> = [["A", "a", "b", "c"], ["B", "b", "c", "d"], ["C", "c", "d", "e"]]
    // Control for pull to refresh
    private let refreshControl = UIRefreshControl()
    // Name of the new added list
    private var newListName = ""
    // Name of the previous list
    private var prevListName = ""
    // Boolean specifying if the user is adding or editing a list
    private var isAdding = false
    // Index of the selected cell
    private var selectedIndex = -1
    
    // Color Palette
    // #d0fcff, #d0ecff, #d0dcff, #d0ccff, #d0bcff
    // #e2f3ff
    // UIColor(red:0.89, green:0.95, blue:1.00, alpha:1.0)
    // #e2eaff
    // UIColor(red:0.89, green:0.92, blue:1.00, alpha:1.0)
    // #e2e0ff
    // UIColor(red:0.89, green:0.88, blue:1.00, alpha:1.0)
    private var colors: Array<UIColor> = [UIColor(red:0.89, green:0.95, blue:1.00, alpha:1.0), UIColor(red:0.89, green:0.92, blue:1.00, alpha:1.0), UIColor(red:0.89, green:0.88, blue:1.00, alpha:1.0)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        // save changes to data model
//        DataModel.sharedInstance.updateData(to: displayList)
        
        // change display
        reverseSaveBtn(withAlpha: 0.5)
        if isAdding {
            // add a new entry to displayList
            displayList.append([newListName])
            let indexPath: IndexPath = [0, displayList.count - 1]
            tableView.insertRows(at: [indexPath], with: .fade)
            let cell : UITableViewCell = tableView.cellForRow(at: indexPath)!
            cell.textLabel?.text = newListName
            // TODO: jump to main view
            
            
        } else if isNew(newListName) {
            // update displayList
            displayList[selectedIndex][0] = newListName
            let cell : UITableViewCell = tableView.cellForRow(at: [0, selectedIndex])!
            cell.textLabel?.text = newListName
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
            self.selectedIndex = editActionsForRowAt.row
            let cell = tableView.cellForRow(at: editActionsForRowAt)
            self.prevListName = (cell?.textLabel?.text)!
            self.displayPopUp()
        }
        edit.backgroundColor = .lightGray
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            // TODO: delete the row from local file perminantly
            //
            
            // delete the row from display(screen)
            self.deleteFromDisplay(at: editActionsForRowAt)
        }
        delete.backgroundColor = .blue
        
        return [delete, edit]
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: go to main view to display contents of the list
        
        // mark this list as selected
        
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let celltry = self.tableView.dequeueReusableCell(withIdentifier: "listcell") {
            cell = celltry
        } else {
            cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "listcell")
        }
        
        // configure the cell
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        cell.backgroundColor = self.colors[indexPath.row % 3]
        let sublist = self.displayList[indexPath.row]
        cell.textLabel?.text = sublist[0]
        cell.detailTextLabel?.text = sublistToString(sublist)
        
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
        let sublist = list.dropFirst()
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
            popUpLabel.text = "Add a new list"
            textField.text = ""
            textField.placeholder = "..."
        } else {
            popUpLabel.text = "Edit list name"
            textField.text = prevListName
        }
    }
    
    // Go back to list view, and adjust display accordingly
    private func backToListView() {
        textField.resignFirstResponder()
        isAdding = false
        hidePopUp()
        selectedIndex = -1
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
