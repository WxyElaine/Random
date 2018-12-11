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
    private var dataTemp: Array<Array<String>> = [
    ["0", "Ave", "University Kitchen", "Yummy Bites", "Taste of Xi'an", "The Burger Place", "uk"],
    ["0", "What's next?", "Study", "Sleep", "Video games", "Eat"],
    ["1", "CSE", "311", "351", "391", "331", "332", "333", "341", "344", "440", "481", "451"],
    ["0", "MATH", "381"]]
    
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
        
        
        
        
        // TODO: try out json
        if self.data != nil {
            // convert data to JSON formatted array
            var dataDict = [String: Any]()
            for i in 0..<self.data!.count {
                let sublist = self.data![i]
                let entry = [
                    "selected": sublist[0],
                    "name": sublist[1],
                    "items": Array(sublist.dropFirst(2))
                    ] as [String : Any]
                dataDict[String.init(describing: i)] = entry
            }
            let jsonFormatted = ["lists": dataDict]
            
            // create a JSON data
            let jsonData = createJson(from: jsonFormatted)
            
            // parse the JSON data
            if jsonData != nil {
                let parsedData = parseJson(from: jsonData!)
//                print(parsedData)
            }
        }
    }
    
    // Create a JSON data out of the given JSON formatted array of dictionary,
    // return the JSON data if succeed, otherwise return nil
    public func createJson(from jsonFormatted: [String: Any]) -> Data? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonFormatted, options: JSONSerialization.WritingOptions.prettyPrinted)
            return jsonData
        } catch {
            print("ERROR in JSON creating: \(error)")
            return nil
        }
    }
    
    // Parse the JSON data into an array of dictionary,
    // return the array if succeed, otherwise return nil
    public func parseJson(from jsonData: Data) -> [String: Any]? {
        do {
            let data = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
            return data
        } catch {
            print("ERROR in JSON parsing: \(error)")
            return nil
        }

    }
}
