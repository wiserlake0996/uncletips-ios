//
//  Todo.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 5/25/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import Foundation

class Todo{
    
    var id:String
    var name:String
    var settings:TodoSettings
    
    init(id:String, name:String)
    {
        self.id = id
        self.name = name
        self.settings = TodoSettings()
    }
    
}

struct TodoSettings{
 
    var locationEntry:Bool?
    var locationExit:Bool?
    
    var randomTime:TimeInterval?
    var fixedTime:Date?
    
    var radius:Double
    
    var suggestions:Bool?
    
    var notificationEmail:String?
    
    var timeAllocation:Double?
    init(){
        radius = 100
    }
    
}
