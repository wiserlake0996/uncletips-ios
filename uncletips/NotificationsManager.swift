//
//  NotificationsManager.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 6/15/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class NotificationsManager{
    
    static let sharedInstance = NotificationsManager()
    fileprivate let locationManager = CLLocationManager()
    var currentLocation:CLLocationCoordinate2D?
    
    var todos = [Todo]()
    var places = [Place]()

    fileprivate init(){
        
    }
    
    //MARK: UINotification
    
    func createRandomLocalReminder(_ todo:Todo, place:Place, interval:TimeInterval){
        let localNotification:UILocalNotification = UILocalNotification()
        localNotification.alertTitle = "Random alert for Todo"
        localNotification.alertBody = todo.name + " at location (\(place.name))"
        localNotification.alertAction = "open"
        
        
        localNotification.fireDate = Date(timeIntervalSinceNow: interval)
        localNotification.soundName = "Default"
        localNotification.userInfo = ["id": todo.id, "alertType":"random", "randomTime":interval]
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    
    func createFixedLocalReminder(_ todo:Todo, place:Place, date:Date){
        let localNotification:UILocalNotification = UILocalNotification()
        localNotification.alertTitle = "Fixed alert for Todo"
        localNotification.alertBody = todo.name + " at location (\(place.name))"
        localNotification.alertAction = "open"
        
        localNotification.fireDate = date
        localNotification.soundName = "Default"
        localNotification.userInfo = ["id": todo.id, "alertType":"fixed", "fixedTime":date]
        UIApplication.shared.scheduleLocalNotification(localNotification)
        
    }
    
    func removeRandomTimeReminder(_ id:String){
        for notification in UIApplication.shared.scheduledLocalNotifications!  { // loop through notifications...
            if (notification.userInfo!["id"] as! String == id && notification.userInfo!["alertType"] as! String == "random") {
                UIApplication.shared.cancelLocalNotification(notification) // there should be a maximum of one match on UUID
                break
            }
        }
    }
    
    
    func removeFixedTimeReminder(_ id:String){
        for notification in UIApplication.shared.scheduledLocalNotifications!  { // loop through notifications...
            if (notification.userInfo!["id"] as! String == id && notification.userInfo!["alertType"] as! String == "fixed") {
                UIApplication.shared.cancelLocalNotification(notification) // there should be a maximum of one match on UUID
                break
            }
        }
    }
    
    
    //MARK: Region monitoring
    
    func createRegion(_ todo: Todo, place:Place, onExit: Bool, onEntry:Bool, radius: Double) -> CLCircularRegion{
        let coordinate = CLLocationCoordinate2DMake(place.lat, place.lng)
        let region = CLCircularRegion(center: coordinate, radius: radius, identifier: todo.id)
        region.notifyOnExit = onExit
        region.notifyOnEntry = onEntry
        
        return region
    }
    
    
    func startMonitoringForRegion(_ todo: Todo, place:Place, onExit:Bool, onEntry:Bool, radius: Double){
        
        for monitored: CLRegion in locationManager.monitoredRegions {
            if monitored.identifier == todo.id{
                stopMonitoringRegion(todo)
            }
        }
        
        let region = createRegion(todo, place: place, onExit: onExit, onEntry: onEntry, radius: radius)
        DataService.sharedInstance.saveRegionInfo(todo, place: place)
        
        locationManager.startMonitoring(for: region)
    }
    
    func stopMonitoringRegion(_ todo:Todo){
        for monitored: CLRegion in locationManager.monitoredRegions {
            
            if monitored.identifier == todo.id{
                locationManager.stopMonitoring(for: monitored)
                DataService.sharedInstance.deleteRegionInfo(todo.id)
                break
            }
        }
    }
    
    func clearAllMonitoredRegions(){
        for monitored: CLRegion in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: monitored)
            
        }
    }
    
    func clearEverything(){
        clearAllNotifications()
        clearAllMonitoredRegions()
    }
    
    func clearAllNotifications(){
        for notification in UIApplication.shared.scheduledLocalNotifications!  { // loop through notifications...
            UIApplication.shared.cancelLocalNotification(notification) // there should be a maximum of one match on UUID
            
        }
    }
    
    
    func showSimpleAlertWithTitle(_ title: String!, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func setCurrentLocation(_ location: CLLocationCoordinate2D){
        currentLocation = location
    }
    
    func getCurrentLocation() -> CLLocationCoordinate2D?{
        return currentLocation
    }
    
    func setTodosAndPlaces(_ todo:[Todo], place:[Place]){
        todos = todo
        places = place
    }
    
    func getTodos() ->([Todo])
    {
        return todos
    }
    
    func getPlaces() ->([Place])
    {
        return places
    }
    
}
