//
//  SuggestionsTableViewController.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 5/22/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class SuggestionsTableViewController: UITableViewController, PlacesSuggestionsDelegate, CLLocationManagerDelegate, SuggestionsDistanceDelegate{
 
    let testSearchWords = ["burger","bar","club","grocery","cafe"]
    var todos = [Todo]()
    var suggestionsTodo = [Todo]()
    var suggestedPlaces = [[Place]]()
    var suggestionsJourney = [[Journey]]()
    
    var placesSearch = GooglePlacesApi()
    
    let locationManager = CLLocationManager()
    
    var distanceSearch = GoogleDistanceApi()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        placesSearch.suggestionsDelegate = self
        distanceSearch.distanceSuggestDelegate = self
      //  loadTodoData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()

        loadTodoData()
        refreshTableData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshSuggestedPlaces()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refresh(_ sender: AnyObject) {
        tableView.reloadData()
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return suggestionsTodo.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return suggestedPlaces[section].count
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionsTableViewCell", for: indexPath) as! SuggestionsTableViewCell

        let name = suggestedPlaces[indexPath.section][indexPath.row].name
        let address = suggestedPlaces[indexPath.section][indexPath.row].address
        
        var openStatus = "OPEN"
        
        if indexPath.row < suggestionsJourney[indexPath.section].count{
            if suggestionsJourney[indexPath.section][indexPath.row].distance != nil{
                let distance = suggestionsJourney[indexPath.section][indexPath.row].distance
                let duration = suggestionsJourney[indexPath.section][indexPath.row].duration
            
                cell.distanceLabel.text = distance
                cell.durationLabel.text = duration
                
                if let tra = suggestionsJourney[indexPath.section][indexPath.row].traffic{
                    cell.distanceLabel.text = tra + " - with traffic"
                }
            }
        }
        
        if let stat = suggestedPlaces[indexPath.section][indexPath.row].openStatus{
            if !stat{
                openStatus = "CLOSED"
            }
        }

        cell.nameLabel.text = "\(name) - (\(openStatus))"
        cell.addressLabel.text = address
        return cell
    }

 
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if let time = suggestionsTodo[section].settings.timeAllocation{
            return "TODO: " + suggestionsTodo[section].name + " (\(Int(time/60))hr \(Int(time.truncatingRemainder(dividingBy: 60)))min(s))"
        }
        
        return "TODO: " + suggestionsTodo[section].name
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        header.textLabel!.textColor = UIColor.red
        header.textLabel!.font = UIFont.boldSystemFont(ofSize: 15)
        header.textLabel!.frame = header.frame
        header.textLabel!.textAlignment = NSTextAlignment.center
    }
 
    
    //MARK: Delegates
    
    func placesSuggestions(_ places: GooglePlacesApi, forPlacesResult data: [Place], forTodoId todoId: Int) {
        print(data)

        
        DispatchQueue.main.async(execute: {
        
            for (i,d) in data.enumerated(){
                let newIndexPath = IndexPath(row: self.suggestedPlaces[todoId].count, section: todoId)
                self.suggestedPlaces[todoId].append(d)
                self.tableView.insertRows(at: [newIndexPath], with: .bottom)
                
                if i == 7{
                    break;
                }
            }
            
            self.tableView.reloadData()

            
            if todoId == (self.suggestionsTodo.count - 1){
                self.refreshSuggestionsJourneyData()
            }
           // self.tableView.reloadData()

        })
    }
    
    
    func distanceApi(_ distanceApi: GoogleDistanceApi, todoSuggestionsDistance data: [Journey], todoId: Int) {

       // print(data)

        DispatchQueue.main.async(execute: {

            self.suggestionsJourney[todoId] = data
            self.tableView.reloadData()
        })
        
    }
    
    
    
    //MARK: Methods
    
    func searchForPlaces(_ query:String, todoId: Int){
        
        if let loc = getCurrentLocation(){
            placesSearch.searchPlacesSuggestionWithDelegate(query, radius: 1500, latitude: loc.0, longitude: loc.1, options: nil, todoId: todoId)
        }else{
            NotificationsManager.sharedInstance.showSimpleAlertWithTitle("Error", message: "no current location data", viewController: self)
        }

    }
    
    func getCurrentLocation() -> (String,String)?{
        if let location = NotificationsManager.sharedInstance.getCurrentLocation(){
            return ("\(location.latitude)","\(location.longitude)")
        }
        
        return nil
    }
    
    func extractTodoKeywords(_ todo:Todo) -> String?{
        let text = todo.name
        let textSplit = text.components(separatedBy: " ")
        
        for w in textSplit{
            for tw in testSearchWords{
                if w == tw{
                    return w
                }
            }
        }
        return nil
    }
    
    func selectTodosForSuggestion() -> [Todo]?{
        var td = [Todo]()
        
        for t in todos{
            if let sug = t.settings.suggestions{
                if sug{
                    td.append(t)
                }
            }
        }
        
        if td.count > 0{
            return td
        }
        return nil
        
    }
    
    func loadTodoData(){
        //self.todos.removeAll()
        self.todos = NotificationsManager.sharedInstance.getTodos()
        
        if let selected = selectTodosForSuggestion(){
            suggestionsTodo.removeAll()
            for s in selected{
                suggestionsTodo.append(s)
            }
        }else{
            print("none selected")
        }
    }

    
    func refreshTableData(){

        suggestedPlaces.removeAll()
        suggestionsJourney.removeAll()
        
        for _ in suggestionsTodo{
            suggestedPlaces.append([Place]())
            suggestionsJourney.append([Journey]())
        }
        self.tableView.reloadData()
        
    }
    
    func refreshSuggestedPlaces(){
        for (i,all) in suggestionsTodo.enumerated(){
            
            if let td = extractTodoKeywords(all){
                searchForPlaces(td, todoId: i)
            }else{
                print("no keywords")
            }
        }
    }
    
    func refreshSuggestionsJourneyData(){
        var options = [String:String]()
        options["traffic_model"] = "best_guess"
        options["mode"] = "driving"
        options["departure_time"] = "now"
        
        if let loc = getCurrentLocation(){
            for (i,pl) in suggestedPlaces.enumerated(){
                
                let destination = placesToWaypointString(pl).stringByAddingPercentEncodingForURLQueryParameter()
                let origin = "\(loc.0),\(loc.1)".stringByAddingPercentEncodingForURLQueryParameter()
                    
                distanceSearch.requestSuggestionsDistanceWithDelegate(origin!, destinations: destination!, options: urlEncodeOptions(options), todoId: i)
            }
        }
    }

    
    
    //MARK: LOCATION
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        NotificationsManager.sharedInstance.setCurrentLocation(manager.location!.coordinate)
        locationManager.stopUpdatingLocation()
        
    }
}
