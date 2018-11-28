//
//  DataModel.swift
//  Random
//
//  Created by Xinyi Wang on 11/6/18.
//  Copyright © 2018 Xinyi Wang. All rights reserved.
//

import Foundation

class DataModel {
    static var sharedInstance = DataModel()
    
    private init() { }
    
    // The structure of data: an array of list of items
    //   Structure of each sublist:
    //     size: at least 2
    //     header:
    //      [0]: selection indicator of whether the list is selected
    //           0: not selected, 1: selected
    //           (note: can only have one list selected at one time)
    //      [1]: list name
    //     other indices: items in the list
    private (set) var data: Array<Array<String>>? {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update"), object: nil)
        }
    }
    
    // TODO: change this
    private var dataTemp: Array<Array<String>> = []
//    [
//    ["1", "Ave", "川宗", "富临轩", "西安味道", "唐朝", "center table", "uk"],
//    ["0", "A", "a", "b", "c"],
//    ["0", "B", "b", "c", "d"],
//    ["0", "C", "c", "d", "e"]]
    
    // Update data of one of the sublist
    public func updateData(to newData: Array<String>) {
        // find the newData(the sublist) in data
        if (data != nil) {
            let index = data!.firstIndex(where: { $0[0] == "1" })
            if index != nil {
                var newSublist: Array<String> = []
                newSublist.append(data![index!][0])
                newSublist.append(data![index!][1])
                for newEntry in newData {
                    newSublist.append(newEntry)
                }
                data![index!] = newSublist
                
                // TODO: delete this
                dataTemp = data!
                
                // TODO: save to local file

            }
        }
    }
    
    // Update the list header
    // change selection indicator only:
    //      prev: prevous index
    //      new: new index
    //      toName: nil
    // change name of sublist only:
    //      prev: index of the sublist to change
    //      new: -1
    //      toName: new name of the sublist
    public func updateHeader(prev prevIndex: Int, new newIndex: Int, toName newName: String?) {
        if (data != nil) {
            if (newName == nil) {
                // change the selection indicator
                if (prevIndex > -1) {
                    data![prevIndex][0] = "0"
                }
                data![newIndex][0] = "1"
            } else {
                // change the name of sublist
                data![prevIndex][1] = newName!
            }
            
            // TODO: delete this
            dataTemp = data!
            
            // TODO: save to local file

        }
    }
    
    // Add a new sublist
    public func addData(add newSublist: Array<String>) {
        // add the new sublist
        if (data != nil) {
            data!.append(newSublist)
            
            // TODO: delete this
            dataTemp = data!
            
            // TODO: save to local file

        }
    }
    
    // Delete a sublist
    public func deleteData(deleteAt index: Int) {
        if (data != nil) {
            data?.remove(at: index)
            
            // TODO: delete this
            dataTemp = data!
            
            // TODO: save to local file

        }
    }
    
    public func requestData() {
        // TODO: fetch data from local file
        
        self.data = dataTemp
    }
}
