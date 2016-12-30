//
//  TodoListTableViewController.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 5/22/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreLocation


class TodoListTableViewController: UITableViewController, GoogleDistanceApiDelegate, CLLocationManagerDelegate {
    
    var todos = [Todo]()
    var places = [Place]()
    var journeys = [Journey]()
    var appeared:Bool = false
    
    var start:Bool = false
    
    var segueTodo:Todo?
    var seguePlace:Place?
    
    var gda:GoogleDistanceApi = GoogleDistanceApi()
    
    let locationManager = CLLocationManager()


    override func viewDidLoad() {
        super.viewDidLoad()

        gda.delegate = self

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.startUpdatingLocation()

        clearTableData()

        let userTodosRef = FIRDatabase.database().reference().child("/todos/guestlake")
        userTodosRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            
   
            if let snapshotValue = snapshot.value as? [String:AnyObject]{
                
                let allValues = snapshotValue
                
                
                for v in allValues.values{
                    
                    if let vk = v as? [String:AnyObject]{

                        let decoded = dictToObjects(vk["settings"]! as! [String:AnyObject], place: vk["place"]! as! [String:AnyObject])
                        
                        
                        let todo = Todo(id: vk["id"]! as! String, name: vk["name"]! as! String)
                        todo.settings = decoded.0
                        
                        let placeData = decoded.1
                        
                        let newIndexPath = IndexPath(row: self.todos.count, section: 0)
                        
                        self.todos.append(todo)
                        self.places.append(placeData)
                        
                        self.tableView.insertRows(at: [newIndexPath], with: .bottom)
                    }
                    
                }


            }
            


            
            
    
            self.appeared = true
            self.tableView.reloadData()
            self.refreshJourneryData()
            NotificationsManager.sharedInstance.setTodosAndPlaces(self.todos, place: self.places)
 
 

        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return todos.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Configure the cell...
        let cellIdentifier = "TodoTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TodoTableViewCell
        
        let todo = todos[indexPath.row]
        let place = places[indexPath.row]
        
        cell.nameLabel.text = todo.name
        cell.placeLabel.text = place.name
        cell.journeyLabel.text = "refreshing data"

        
        if journeys.count > 0{
            let j =  journeys[indexPath.row]
            cell.journeyLabel.text = j.formattedJourney()
        }
        


        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        segueTodo = todos[indexPath.row]
        seguePlace = places[indexPath.row]
        self.performSegue(withIdentifier: "ListOpenTodo", sender: self)
    }
    
    
    //MARK: Methods
    
    func clearTableData(){
        todos.removeAll()
        places.removeAll()
        self.tableView.reloadData()
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            DataService.sharedInstance.deleteTodo(todos[indexPath.row].id)
            todos.remove(at: indexPath.row)
            places.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
  
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    func distanceApi(_ distanceApi: GoogleDistanceApi, distanceCalculationResponse data: [Journey]) {
     //   print(data)
        DispatchQueue.main.async(execute: {
            self.journeys = data
            self.tableView.reloadData()
        })
        
    }
  
    
    //MARK: Methods
    
    func refreshJourneryData(){
        if let curr =  NotificationsManager.sharedInstance.getCurrentLocation(){

            let destination = placesToWaypointString(places)
            let origin = "\(curr.latitude),\(curr.longitude)"
            
            var options = [String:String]()
            options["traffic_model"] = "best_guess"
            options["mode"] = "driving"
            options["departure_time"] = "now"
            
            gda.requestDistanceWithDelegate(origin.stringByAddingPercentEncodingForURLQueryParameter()! , destinations: destination.stringByAddingPercentEncodingForURLQueryParameter()!, options: urlEncodeOptions(options) )
        }
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ListOpenTodo"{
            if let vc = segue.destination as? TodoItemViewController{
                vc.place = seguePlace
                vc.todo = segueTodo
                vc.currentLocation = NotificationsManager.sharedInstance.getCurrentLocation()
                //vc.journey = segueJourney
                //vc.delegate = self
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        NotificationsManager.sharedInstance.setCurrentLocation(manager.location!.coordinate)
        self.refreshJourneryData()
        locationManager.stopUpdatingLocation()

    }
    

}
