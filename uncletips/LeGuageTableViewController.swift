//
//  LeGuageTableViewController.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 6/9/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class LeGuageTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var todos = [Todo]()
    var places = [Place]()
    var waypoints = [Place]()
    var waypointsTodos = [Todo]()
    
    var destinationPlace: Place?
    var destinationTodo: Todo?
    
    var typePickerView: UIPickerView!
    var sectionForPicker:Int?

    var ref:FIRDatabaseReference!

    var appeared:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadSampleData()
        self.ref = DataService.sharedInstance.BASE_REF
        


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        clearTableData()
        
        let userTodosRef = self.ref.child("/todos/guestlake")
        userTodosRef.observeSingleEvent(of: .value, with: {
            (snapshot) -> Void in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        let snSet = postDict["settings"]
                        let snPlace = postDict["place"]
                        
                        let decode = dictToObjects(snSet as! [String : AnyObject], place: snPlace as! [String : AnyObject])
                        
                        let todo = Todo(id: snap.key, name: postDict["name"] as! String )
                        
                        todo.settings = decode.0
                        
                        let placeData = decode.1
                        
                        self.todos.append(todo)
                        self.places.append(placeData)
                    }
                }
            }
            
//            
//            
//            
//            
//            
//            
//            
//            for childSnap in snapshot.children.allObjects{
//                
//                
//                
//                
//                
//                
//                
//                
//                
//                
//                
//                
//                
//                
//                let snap = childSnap as! FIRDataSnapshot
//                
//                if let snapshotValue = snapshot.value as? NSDictionary, let snapVal = snapshotValue[snap.key] as? AnyObject {
//                    print("val" , snapVal)
//                }
//                
//                let snapshotValue = snapshot.value as? NSDictionary
//                
//                
//                
//                
//                let snapSettings = ((data as AnyObject).value!["settings"] as! [String:AnyObject])
//                let snapPlace = ((data as AnyObject).value!["place"] as! [String:AnyObject])
//                
//                let decoded = dictToObjects(snapSettings, place: snapPlace)
//                
//                let todo = Todo(id: (data as AnyObject).key, name: (data as AnyObject).value!["name"] as! String)
//                todo.settings = decoded.0
//                
//                let placeData = decoded.1
//                
//                self.todos.append(todo)
//                self.places.append(placeData)
//                
//            }
            self.appeared = true
            
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func test(_ sender: UIBarButtonItem) {
        //gta.calculateTripDirectionsWithDelegate("edgewater,nj", destination: "fort+lee,nj", waypoints: "hoboken,nj|cliffside+park,nj|north+bergen,NJ".stringByAddingPercentEncodingForURLQueryParameter() , options: "&travel_mode=driving")
    }
    @IBAction func cancel(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: Methods
    
    func clearTableData(){
        todos.removeAll()
        places.removeAll()
        self.tableView.reloadData()
    }
    
    func loadSampleData()
    {
        todos.append(Todo(id: generateUniqueId(), name: "buy milk"))
        todos.append(Todo(id: generateUniqueId(), name: "complete app"))
        todos.append(Todo(id: generateUniqueId(), name: "call richards"))
        todos.append(Todo(id: generateUniqueId(), name: "go to the bank"))
        todos.append(Todo(id: generateUniqueId(), name: "pick up dry cleaning"))
        
        places.append(TodoPlace(id: generateUniqueId(), name: "ACME store", address: "1 Acme place", lat: 0, lng: 0, typeID: todos[0].id))
        places.append(TodoPlace(id: generateUniqueId(), name: "home", address: "9 somerset lane", lat: 0, lng: 0, typeID: todos[1].id))
        places.append(TodoPlace(id: generateUniqueId(), name: "Co cowork space", address: "1 working place", lat: 0, lng: 0, typeID: todos[2].id))
        places.append(TodoPlace(id: generateUniqueId(), name: "Wells Fargo", address: "1 port imperial place", lat: 0, lng: 0, typeID: todos[3].id))
        places.append(TodoPlace(id: generateUniqueId(), name: "Mr Spit shine", address: "1 shine shine place", lat: 0, lng: 0, typeID: todos[4].id))
 
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if section == 2{
            return waypoints.count
        }
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "destinationTableCell", for: indexPath) as! DestinationTableViewCell
            
            if let des = destinationTodo{
                cell.titleLabel.text = des.name
                cell.subtitleLabel.text = "At \(destinationPlace!.name) - \(destinationPlace!.address)"
                
                
            }else{
                cell.titleLabel.text = "Select a destination"
                cell.subtitleLabel.text = "just tap"
            }
            return cell
            
            
        }else if indexPath.section == 1{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "addWaypointTableCell", for: indexPath) as! AddWayPointTableViewCell
            
            cell.titleLabel.text = "Add waypoint"
            
            return cell
            
        }else if indexPath.section == 2{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "waypointTableCell", for: indexPath) as! WaypointTableViewCell
            
            cell.titleLabel.text = waypointsTodos[indexPath.row].name
            cell.subtitleLabel.text = "At \(waypoints[indexPath.row].name) - \(waypoints[indexPath.row].address)"
            return cell
            
        }
        
        let cell = UITableViewCell()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30; // space b/w cells
    }
    

    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Set destination"
        }else if section == 1{
            return "Add waypoints"
        }else if section == 2{
            return "Waypoints"
        }
        
        return "Unnamed section"
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 2{
            cell.contentView.backgroundColor = UIColor.clear
            
            let whiteRoundedView : UIView = UIView(frame: CGRect(x: 0, y: 10, width: self.view.frame.size.width, height: 81))
            
            whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
            whiteRoundedView.layer.masksToBounds = false
            whiteRoundedView.layer.cornerRadius = 2.0
            whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
            whiteRoundedView.layer.shadowOpacity = 0.7
            
            cell.contentView.addSubview(whiteRoundedView)
            cell.contentView.sendSubview(toBack: whiteRoundedView)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            showPicker(1)
        }else if indexPath.section == 0{
            showPicker(0)
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        if indexPath.section == 2{
            return true
        }else{
            return false
        }
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            waypoints.remove(at: indexPath.row)
            waypointsTodos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if sectionForPicker == 1{
            return todos.count
        }else if sectionForPicker == 0{
            return todos.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if sectionForPicker == 1{
            return todos[row].name
        }else if sectionForPicker == 0{
            return todos[row].name
        }
        return "error"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if let viewWithTag = self.view.viewWithTag(1) {
            
            if sectionForPicker! == 1{
                
                let newIndexPath = IndexPath(row: waypoints.count, section: 2)
                waypoints.append(places[row])
                waypointsTodos.append(todos[row])
                self.tableView.insertRows(at: [newIndexPath], with: .bottom)
                
            }else{
                destinationTodo = todos[row]
                destinationPlace = places[row]
            }
            viewWithTag.removeFromSuperview()
        }
        else {
        }
        tableView.reloadData()
        
    }
    
    func showPicker(_ section:Int){
        sectionForPicker = section
        
        if typePickerView != nil{
            if let viewWithTag = self.view.viewWithTag(1) {
                viewWithTag.removeFromSuperview()
            }
        }
        
        typePickerView = UIPickerView(frame: CGRect(x: 0, y: view.frame.height - 270, width: view.frame.width, height: 250))
        self.typePickerView.dataSource = self
        self.typePickerView.delegate = self
        self.typePickerView.backgroundColor = UIColor.yellow
        self.typePickerView.layer.borderColor = UIColor.white.cgColor
        self.typePickerView.tag = 1
        
        self.view.addSubview(typePickerView) //will add the subview to the view hierarchy
        
        self.typePickerView.layer.borderWidth = 1
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "guageResult"{
            
            if let vc = segue.destination as? LeGuageResultViewController{
                vc.destinationPlace = destinationPlace
                vc.destinationTodo = destinationTodo
                vc.waypointTodos = waypointsTodos
                vc.waypointPlaces = waypoints
            }
            
        }
    }
    

}


