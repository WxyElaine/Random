//
//  FirstViewController.swift
//  Random
//
//  Created by Xinyi Wang on 9/10/18.
//  Copyright © 2018 Xinyi Wang. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveBtn: UIButton!
    
    // The name of the list to display
    private var listName = ""
    // The list of items to display
    private var displayList: Array<String> = []
    // Control for pull to refresh
    private let refreshControl = UIRefreshControl()
    // Boolean specifying whether to add a place holder cell
    private var addPlaceHolder = false
    // Index of the item to be deleted from displayList
    private var deleteIndex = -1
    // Number of items in displayList before add button is pushed
    private var prevCount = 0
    // Boolean specifying whether the current list is a valid list in the user's data
    // (i.e. the current list cannot be a placeholder list)
    private var invalidList = true
    
    // Color Palette
    // #e2f3ff
    // UIColor(red:0.89, green:0.95, blue:1.00, alpha:1.0)
    // #e2eaff
    // UIColor(red:0.89, green:0.92, blue:1.00, alpha:1.0)
    // #e2e0ff
    // UIColor(red:0.89, green:0.88, blue:1.00, alpha:1.0)
    private var colors: Array<UIColor> = [
        UIColor(red:0.89, green:0.95, blue:1.00, alpha:1.0),
        UIColor(red:0.89, green:0.92, blue:1.00, alpha:1.0),
        UIColor(red:0.89, green:0.88, blue:1.00, alpha:1.0)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up the observer to listen to data update
        NotificationCenter.default.addObserver(self, selector: #selector(getDataUpdate), name: NSNotification.Name(rawValue: "update"), object: nil)
        // get new data
        DataModel.sharedInstance.requestData()
        
        // set up buttons (disable save button)
        reverseSaveBtn(isEnabled: false, withAlpha: 0.5)
        
        // display list name
        tableTitle.text = listName
        
        // display table view
        addPlaceHolderCellWithRefresh()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(ListTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isScrollEnabled = true
        
        // pull to refresh
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(FirstViewController.refreshData(sender:)), for: .valueChanged)
        
        // disable user interaction if the current list is invalid
        if invalidList {
            disableUserInteraction()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // reload display when user switches to this tab
        tableTitle.text = listName
        addPlaceHolderCellWithRefresh()
        tableView.reloadData()
        if invalidList {
            disableUserInteraction()
        } else {
            enableUserInteraction()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // remove the observer
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "update"), object: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAnswer" {
            let answerViewController = segue.destination as! AnswerViewController
            answerViewController.eventList = self.displayList
        }
    }
    
    // For unwind the segue to answer view
    @IBAction func unwindToFirst(segue: UIStoryboardSegue) {
    }
    
    // For "Add" button
    @IBAction func addNewItem(_ sender: UIButton?) {
        prevCount = displayList.count
        addPlaceHolderCellWithoutRefresh()
    }
    
    // For "Generate" button
    @IBAction func generateResult(_ sender: UIButton) {
        if !displayNoItemWarning() {
            performSegue(withIdentifier: "toAnswer", sender: sender)
        }
    }
    
    // For "Save" button
    @IBAction func saveChanges(_ sender: UIButton) {
        // save changes to data model
        DataModel.sharedInstance.updateData(to: displayList)
        // disable save button
        reverseSaveBtn(isEnabled: false, withAlpha: 0.5)
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
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // TODO: delete the row from local file perminantly
            //
            
            // delete the row from display(screen)
            deleteFromDisplay(at: indexPath)
            // enable save button
            reverseSaveBtn(isEnabled: true, withAlpha: 1.0)
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ListTableViewCell
        if let celltry = self.tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell = celltry as! ListTableViewCell
        } else {
            cell = ListTableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        }
        
        // configure the cell
        cell.label.delegate = self
        cell.label.adjustsFontSizeToFitWidth = true
        cell.backgroundColor = self.colors[indexPath.row % 3]
        if addPlaceHolder {
            // add a placeholder cell
            cell.label.text = ""
            addPlaceHolder = false
        } else {
            cell.label.text = self.displayList[indexPath.row]
        }
        cell.label.placeholder = "Tap to enter an item"

        return cell
    }

    // Text field editing settings
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if deleteIndex != -1 {
            deleteFromDisplay(at: [0, deleteIndex])
            deleteIndex = -1
        }
        // enable save button if changes are detected
        if prevCount != displayList.count {
            reverseSaveBtn(isEnabled: true, withAlpha: 1.0)
        }
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // update the displayList entry
        let cell : ListTableViewCell = textField.superview as! ListTableViewCell
        let index : Int = (tableView.indexPath(for: cell)?.row)!
        // add the edited entry to displayList
        let newEntry: String = textField.text!
        if newEntry != "" {
            displayList[index] = newEntry
        } else {
            // new entry is invalid, delete this entry from table and displayList
            deleteIndex = index
        }
        return true
    }
    
    /* Private Functions */
    
    // Get new data
    @objc private func getDataUpdate() {
        if let data = DataModel.sharedInstance.data {            
            for sublist in data {
                if (sublist[0] == "1") {
                    // the current list is selected, display this list
                    listName = sublist[1]
                    displayList = Array(sublist.dropFirst().dropFirst())
                    invalidList = false
                    enableUserInteraction()
                    break
                }
            }
            // display placeholders if needed
            if data.isEmpty {
                invalidList = true
            }
            if invalidList {
                listName = "Nothing Here"
                displayList = []
                disableUserInteraction()
            }
        }
    }
    
    // Refresh table entries (for pull to refresh)
    @objc private func refreshData(sender: UIRefreshControl) {
        addPlaceHolderCellWithRefresh()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }

    // Add a place holder cell, the cell will be added after reload table
    private func addPlaceHolderCellWithRefresh() {
        if displayList.isEmpty || (displayList.count == 1 && displayList[0] == "") {
            // add a placeholder cell in the table
            if displayList.isEmpty {
                displayList.append("")
            }
            addPlaceHolder = true
        }
    }
    
    // Add a place holder cell immediately, and returns the new cell
    private func addPlaceHolderCellWithoutRefresh() {
        // add cell to table view
        displayList.append("")
        tableView.reloadData()
        
        // scroll to the newly-added cell
        let indexPath = IndexPath(row: self.displayList.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        
        // TODO: display keyboard
        // TODO: TODO
//        let cell = tableView.cellForRow(at: indexPath) as! ListTableViewCell
//        cell.label.becomeFirstResponder()

        
    }
    
    // TODO: DELETE THIS
    // Automatically scroll to the bottom of table view
    private func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.displayList.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    // Display an alert when "Generate" button is pressed but there is no item
    private func displayNoItemWarning() -> Bool {
        if displayList.isEmpty || (displayList.count == 1 && displayList[0] == "") {
            // display a warning rather than generate result
            let noItemAlert = UIAlertController(title: "Umm...", message: "Please enter something first!", preferredStyle: UIAlertControllerStyle.alert)
            noItemAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            }))
            present(noItemAlert, animated: true, completion: nil)
            return true
        }
        return false
    }
    
    // Delete a cell from display
    private func deleteFromDisplay(at indexPath: IndexPath) {
        // update the cell background
        var cell: ListTableViewCell
        for i in indexPath.row + 1..<displayList.count {
            cell = tableView.cellForRow(at: [0, i]) as! ListTableViewCell
            cell.backgroundColor = self.colors[(i - 1) % 3]
        }
        // delete from displayList
        displayList.remove(at: indexPath.row)
        // delete the row from table
        tableView.deleteRows(at: [indexPath], with: .fade)
        // add a placeholder cell if displayList is now empty
        if displayList.isEmpty {
            addPlaceHolderCellWithoutRefresh()
        }
    }
    
    // Enable or disable the save button and set its alpha to the given value
    private func reverseSaveBtn(isEnabled status: Bool, withAlpha alpha: Float) {
        saveBtn.isEnabled = status
        saveBtn.alpha = CGFloat(alpha)
        var color = UIColor.black
        if (!status) {
            color = UIColor(red:0.65, green:0.65, blue:0.65, alpha:1.0)
        }
        saveBtn.setTitleColor(color, for: [])
    }
    
    // Disable user interaction of the whole view
    private func disableUserInteraction() {
        view.isUserInteractionEnabled = false
        view.alpha = CGFloat(0.5)
    }
    
    // Enable user interaction of the whole view
    private func enableUserInteraction() {
        view.isUserInteractionEnabled = true
        view.alpha = CGFloat(1.0)
    }
    
    
    
    
    // TODO: MODIFY THIS
    // TODO: automatically scroll to the editing text field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textfield: textField, moveDistance: -250, up: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textfield: textField, moveDistance: -250, up: false)
    }

    func moveTextField(textfield: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance: -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.tableView.frame = self.tableView.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}
