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
        
        // set up the observer to listen to data update
        NotificationCenter.default.addObserver(self, selector: #selector(getDataUpdate), name: NSNotification.Name(rawValue: "update"), object: nil)
        // get new data
        DataModel.sharedInstance.requestData()
        
        // set up buttons
        reverseSaveBtn(withAlpha: 0.5)
        
        // display table view
        addPlaceHolderCellWithRefresh()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(ListTableViewCell.self, forCellReuseIdentifier: "cell")
        
        // pull to refresh
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(FirstViewController.refreshData(sender:)), for: .valueChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func addNewItem(_ sender: UIButton) {
        prevCount = displayList.count
        let cell : ListTableViewCell = addPlaceHolderCellWithoutRefresh()
        // display keyboard
        cell.label.becomeFirstResponder()
    }
    
    @IBAction func generateResult(_ sender: UIButton) {
        if !displayNoItemWarning() {
            performSegue(withIdentifier: "toAnswer", sender: sender)
        }
    }
    
    @IBAction func saveChanges(_ sender: UIButton) {
        // save changes to data model
        DataModel.sharedInstance.updateData(to: displayList)
        reverseSaveBtn(withAlpha: 0.5)
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
            reverseSaveBtn(withAlpha: 1.0)
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
            cell.label.placeholder = "Tap to enter an item"
            addPlaceHolder = false
        } else {
            cell.label.text = self.displayList[indexPath.row]
        }

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
            reverseSaveBtn(withAlpha: 1.0)
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
    
    // Private Functions
    
    // Get new data
    @objc private func getDataUpdate() {
        if let data = DataModel.sharedInstance.data {
            displayList = data
        }
    }
    
    // Refresh table entries
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
    private func addPlaceHolderCellWithoutRefresh() -> ListTableViewCell {
        displayList.append("")
        let indexPath: IndexPath = [0, displayList.count - 1]
        tableView.insertRows(at: [indexPath], with: .fade)
        let cell : ListTableViewCell = tableView.cellForRow(at: indexPath) as! ListTableViewCell
        cell.label.placeholder = "Tap to enter an item"
        return cell
    }
    
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
            let _ = addPlaceHolderCellWithoutRefresh()
        }
    }
    
    // Enable or disable the save button and set its alpha to the given value
    private func reverseSaveBtn(withAlpha alpha: Float) {
        saveBtn.isEnabled = !saveBtn.isEnabled
        saveBtn.alpha = CGFloat(alpha)
        var color = UIColor.black
        if (alpha == 0.5) {
            color = UIColor(red:0.65, green:0.65, blue:0.65, alpha:1.0)
        }
        saveBtn.setTitleColor(color, for: [])
    }
}
