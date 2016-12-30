//
//  DataService.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 6/4/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class DataService{
    
    static let sharedInstance = DataService()
    
    fileprivate var _BASE_REF = FIRDatabase.database().reference()
    
    let userId:String = "guestlake"
    
    
    fileprivate init()
    {
    }
    
    var BASE_REF: FIRDatabaseReference {
        return _BASE_REF
    }
    
    var USER_REF: FIRDatabaseReference {
        return _BASE_REF.child("/users")
    }
    
    var TODO_REF: FIRDatabaseReference {
        return _BASE_REF.child("/todos")
    }
    
    func createNewTodo(_ todo: Dictionary<String, AnyObject>) {
        
        
        if let uid = UserDefaults.standard.value(forKey: "uid"){
            let firebaseNewTodo = TODO_REF.child("\(uid)/\(todo["id"]!)")
            firebaseNewTodo.setValue(todo)
        }else{
            let firebaseNewTodo = TODO_REF.child("guestlake/\(todo["id"]!)")
            firebaseNewTodo.setValue(todo)
        }
        
        
    }
    
    func updateTodo(_ todo: Dictionary<String, AnyObject>){
        
        if let uid = UserDefaults.standard.value(forKey: "uid"){
            let firebaseNewTodo = TODO_REF.child("\(uid)/\(todo["id"]!)")
            firebaseNewTodo.updateChildValues(todo)
        }else{
            let firebaseNewTodo = TODO_REF.child("guestlake/\(todo["id"]!)")
            firebaseNewTodo.updateChildValues(todo)
        }
    }
    
    func deleteTodo(_ id:String){
        
        if let uid = UserDefaults.standard.value(forKey: "uid"){
            let firebaseNewTodo = TODO_REF.child("\(uid)/\(id)")
            firebaseNewTodo.removeValue()
        }else{
            let firebaseNewTodo = TODO_REF.child("guestlake/\(id)")
            firebaseNewTodo.removeValue()
        }
    }
    
    func saveRegionInfo(_ todo:Todo, place:Place){
        let defaults = UserDefaults.standard

        let data:[String:String] = ["todo":todo.name, "place":place.name]
        
        defaults.set(data, forKey: todo.id)
    }
    
    func loadRegionInfo(_ id:String) -> String{
        
        let defaults = UserDefaults.standard

        var text:String = "location notification"
        
        let data = defaults.object(forKey: id) as? [String:String]!
        
        if data != nil{
            text = "reminder for \(data!["todo"]!) at \(data!["place"]!)"
        }
        
        return text
        
        
    }
    
    func deleteRegionInfo(_ id:String){
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: id)
    }
    
    
}
