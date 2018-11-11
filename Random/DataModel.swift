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
    
    private (set) var data: Array<String>? {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update"), object: nil)
        }
    }
    
    public func updateData(to newData: Array<String>) {
        data = newData
    }
    
    public func requestData() {
        // TODO: fetch data from local file
        self.data = ["Ave", "川宗", "富临轩", "西安味道", "唐朝", "center table", "uk"]
    }
}
