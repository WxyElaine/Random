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
    //     [0]: indicator of whether the list is selected
    //          0: not selected, 1: selected
    //          (note: can only have one list selected at one time)
    //     [1]: list name
    //     other indices: items in the list
    private (set) var data: Array<Array<String>>? {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update"), object: nil)
        }
    }
    
    // TODO: change this
    private var dataTemp: Array<Array<String>> = [
    ["1", "Ave", "川宗", "富临轩", "西安味道", "唐朝", "center table", "uk"],
    ["0", "A", "a", "b", "c"],
    ["0", "B", "b", "c", "d"],
    ["0", "C", "c", "d", "e"]]
    
    public func updateData(to newData: Array<String>) {
        // find the newData(the sublist) in data
        if (data != nil) {
            let index = data!.firstIndex(where: { $0[0] == "1" })
            var newSublist: Array<String> = []
            newSublist.append(data![index!][0])
            newSublist.append(data![index!][1])
            for newEntry in newData {
                newSublist.append(newEntry)
            }
            data![index!] = newSublist
            
            // TODO: delete this
            dataTemp = data!
        }
    }
    
    public func requestData() {
        // TODO: fetch data from local file
//        self.data = [
//            ["1", "Ave", "川宗", "富临轩", "西安味道", "唐朝", "center table", "UK"],
//            ["0", "A", "a", "b", "c"],
//            ["0", "B", "b", "c", "d"],
//            ["0", "C", "c", "d", "e"]]
        self.data = dataTemp
    }
}
