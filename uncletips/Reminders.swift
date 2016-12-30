//
//  Reminders.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 5/31/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class Reminders{
    
    let locationManager = CLLocationManager()
    
    func setReminder(_ todo:Todo, place:Place){
        setTimedReminder(todo, place: place)
        setLocationReminder(todo, place: place)
    }
    
    func setTimedReminder(_ todo:Todo, place:Place){
        
        if todo.settings.fixedTime == nil && todo.settings.randomTime == nil{
            
            removeRandomTimeReminder(todo.id)
            removeFixedTimeReminder(todo.id)
            
        }else{
            
            if let randTime:TimeInterval = todo.settings.randomTime{
                
                if randomTimeChanged(todo.id, time: randTime){
                    removeRandomTimeReminder(todo.id)
                    createRandomLocalReminder(todo, place: place, interval: randTime)
                }
            }
            if let fixedTime:Date = todo.settings.fixedTime as Date?{
                
                if fixedTimeChanged(todo.id, time: fixedTime){
                    removeFixedTimeReminder(todo.id)
                    createFixedLocalReminder(todo, place: place, date: fixedTime)
                }
            }
        }
        
    }
    
    func setLocationReminder(_ todo:Todo, place:Place){
        
        var onExit:Bool = false
        var onEntry:Bool = false
        
        if todo.settings.locationEntry == nil && todo.settings.locationExit == nil{
            stopMonitoringRegion(todo)
        }else{
            
            if let exit = todo.settings.locationExit{
                onExit = exit
            }
            
            if let entry = todo.settings.locationEntry{
                onEntry = entry
            }
            
            startMonitoringForRegion(todo, place: place, onExit: onExit, onEntry: onEntry, radius: todo.settings.radius)
        }
        
    }
    
    func createRandomLocalReminder(_ todo:Todo, place:Place, interval:TimeInterval){

        NotificationsManager.sharedInstance.createRandomLocalReminder(todo, place:place, interval:interval)
        
    }
    
    func createFixedLocalReminder(_ todo:Todo, place:Place, date:Date){

        NotificationsManager.sharedInstance.createFixedLocalReminder(todo, place:place, date:date)
        
    }
    
    func removeRandomTimeReminder(_ id:String){

        NotificationsManager.sharedInstance.removeRandomTimeReminder(id)
    }
    
    
    func removeFixedTimeReminder(_ id:String){

        NotificationsManager.sharedInstance.removeFixedTimeReminder(id)
    }
    
    func startMonitoringForRegion(_ todo: Todo, place:Place, onExit:Bool, onEntry:Bool, radius: Double){

        NotificationsManager.sharedInstance.startMonitoringForRegion(todo, place: place, onExit: onExit, onEntry: onEntry, radius: radius)
    }
    
    func stopMonitoringRegion(_ todo:Todo){

        NotificationsManager.sharedInstance.stopMonitoringRegion(todo)
    }
    
    func clearAllMonitoredRegions(){
        NotificationsManager.sharedInstance.clearAllMonitoredRegions()
    }
    
    func removeEmailReminder(){
        
    }
    
    
    func createEmailReminder(){
        
    }
    
    
    func fixedTimeChanged(_ id:String, time:Date) -> Bool{
        
        for notification in UIApplication.shared.scheduledLocalNotifications!  { // loop through notifications...
            if (notification.userInfo!["id"] as! String == id && notification.userInfo!["alertType"] as! String == "fixed") {
                
                if (notification.userInfo!["fixedTime"] as! Date == time){
                    return false
                }
            }
        }
        
        return true
    }
    
    
    func randomTimeChanged(_ id: String, time:TimeInterval) -> Bool{
        for notification in UIApplication.shared.scheduledLocalNotifications!  { // loop through notifications...
            if (notification.userInfo!["id"] as! String == id && notification.userInfo!["alertType"] as! String == "random") {
                
                if (notification.userInfo!["randomTime"] as! TimeInterval == time){
                    return false
                }
            }
        }
        
        return true
    }
    
    
    func removeAllReminders(_ todo:Todo){
        
        NotificationsManager.sharedInstance.removeFixedTimeReminder(todo.id)
        NotificationsManager.sharedInstance.removeRandomTimeReminder(todo.id)
        NotificationsManager.sharedInstance.stopMonitoringRegion(todo)
    }
    
    func clearEverything(){
        NotificationsManager.sharedInstance.clearEverything()
    }
    
    func clearAllNotifications(){
        NotificationsManager.sharedInstance.clearAllNotifications()
    }

}
