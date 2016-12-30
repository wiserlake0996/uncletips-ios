//
//  LeGuageViewController.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 6/17/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class LeGuageViewController: UITableViewController , UIPickerViewDataSource, UIPickerViewDelegate, LeGuageOptionsDelegate {

    var waypointsTodo = [Todo]()
    var waypointsPlace = [TodoPlace]()
    
    var todos = [Todo]()
    var places = [TodoPlace]()
    
    var typePickerView: UIPickerView!
    var sectionForPicker:Int?
    
    var selectedPickerRow:Int?
    
    var originTodo:Todo?
    var originAddress:TodoPlace?
    
    var destinationTodo:Todo?
    var destinationAddress:TodoPlace?
    
    var travelOptions:[String:String]?
    
    var refHandler:FIRDatabaseHandle!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        setupToolbar()
       // loadSampleData()
        
        originTodo = Todo(id: generateUniqueId(), name: "current location (default)")
        
        if let currentLocation = NotificationsManager.sharedInstance.getCurrentLocation(){
        
            originAddress = TodoPlace(id: generateUniqueId(), name: "current address", address: "current address (default)", lat: currentLocation.latitude, lng: currentLocation.longitude, typeID: originTodo!.id)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshData()
        let userTodosRef = DataService.sharedInstance.BASE_REF.child("/todos/guestlake")
        
        refHandler = userTodosRef.observe(.childAdded, with: { (data) -> Void in
            
            let dataValue = data.value as? NSDictionary
            
            let snapSettings = dataValue?["settings"] as! [String:AnyObject]
            let snapPlace = dataValue?["place"] as! [String:AnyObject]
            
            let decoded = dictToObjects(snapSettings, place: snapPlace)
            
            let todo = Todo(id: data.key, name: dataValue?["name"] as! String)
            todo.settings = decoded.0
            
            let placeData = decoded.1
            
            self.todos.append(todo)
            self.places.append(placeData)
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DataService.sharedInstance.BASE_REF.removeObserver(withHandle: refHandler)

    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func proceedButton(_ sender: UIBarButtonItem) {
        if destinationTodo != nil && originTodo != nil{
            self.performSegue(withIdentifier: "LeGuageResultController", sender: self)
        }else{
            NotificationsManager.sharedInstance.showSimpleAlertWithTitle("data missing", message: "make sure to enter the origin and destination", viewController: self)
        }
    }
    //MARK: Methods
    
    func setupToolbar(){
        let default_title = ["Done","Cancel"]
        var items: Array<UIBarButtonItem> = []
        
        items.append(UIBarButtonItem(title: default_title[0], style: UIBarButtonItemStyle.bordered, target: self, action: #selector(LeGuageViewController.pickerItemSelected)))
        items.append(UIBarButtonItem(title: default_title[1], style: UIBarButtonItemStyle.bordered, target: self, action: #selector(LeGuageViewController.removePicker)))
        
        
        self.setToolbarItems(items, animated: true)
        
        tableView.separatorColor = UIColor.yellow
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
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 4{
            return waypointsTodo.count
        }
        
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "originCell", for: indexPath)
            if let origin = originTodo{
                cell.textLabel?.text = origin.name
                cell.detailTextLabel?.text = originAddress?.address
            }else{
                cell.textLabel?.text = "set origin"
                cell.detailTextLabel?.text = "DEFAULT: CURRENT LOCATION"
            }
            
            
            return cell
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "destinationCell", for: indexPath)
            
            if destinationTodo != nil{
                cell.textLabel?.text = destinationTodo?.name
                cell.detailTextLabel?.text = destinationAddress?.address
            }else{
                cell.textLabel?.text = "set destination todo"
                cell.detailTextLabel?.text = "set destination address"
            }
            
            
            return cell
        }
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "travelOptionsCell", for: indexPath)
            return cell
        }
        
        if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addWaypointCell", for: indexPath)
            return cell
        }
        
        if indexPath.section == 4 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "waypointCell", for: indexPath)
            cell.textLabel?.text = waypointsTodo[indexPath.row].name
            cell.detailTextLabel?.text = waypointsPlace[indexPath.row].address
            cell.backgroundColor = UIColor.lightGray
            
            return cell
        }
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "non", for: indexPath)
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        if indexPath.section == 4{
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30; // space b/w cells
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "origin data"
        }else if section == 1{
            return "destination data"
        }else if section == 2{
            return "set travel options"
        }else if section == 3{
            return "Add waypoints"
        }else if section == 4{
            return "selected waypoints"
        }
        
        return "Unnamed section"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            showPicker(0)
        }else if indexPath.section == 1{
            showPicker(1)
        }else if indexPath.section == 3{
            showPicker(3)
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            waypointsTodo.remove(at: indexPath.row)
            waypointsPlace.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    
    
    
    //MARK: UIPicker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return todos.count
        }
        return places.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            return todos[row].name
        }
        return places[row].address
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPickerRow = row
        
        if component == 0{
            typePickerView.selectRow(row, inComponent: 1, animated: true)
        }else{
            typePickerView.selectRow(row, inComponent: 0, animated: true)
            
        }
    }
    
    
    
    func showPicker(_ section:Int){
        sectionForPicker = section
        
        if typePickerView != nil{
            if let viewWithTag = self.view.viewWithTag(1) {
                viewWithTag.removeFromSuperview()
            }
        }
        
        typePickerView = UIPickerView(frame: CGRect(x: 0, y: view.frame.height - 380, width: view.frame.width, height: 250))
        self.typePickerView.dataSource = self
        self.typePickerView.delegate = self
        self.typePickerView.backgroundColor = UIColor.clear
        self.typePickerView.layer.borderColor = UIColor.white.cgColor
        self.typePickerView.tag = 1
        self.view.addSubview(typePickerView) //will add the subview to the view hierarchy
        self.typePickerView.layer.borderWidth = 1
        
        self.navigationController?.isToolbarHidden = false
        
    }
    
    
    func pickerItemSelected(){
        if let tag = self.view.viewWithTag(1){
            tag.removeFromSuperview()
        }
        
        self.navigationController?.isToolbarHidden = true
        
        if sectionForPicker == 3{
            let newIndexPath = IndexPath(row: waypointsTodo.count, section: 4)
            waypointsTodo.append(todos[typePickerView.selectedRow(inComponent: 0)])
            waypointsPlace.append(places[typePickerView.selectedRow(inComponent: 1)])
            
            self.tableView.insertRows(at: [newIndexPath], with: .bottom)
        }
        
        if sectionForPicker == 0{
            originTodo = todos[typePickerView.selectedRow(inComponent: 0)]
            originAddress = places[typePickerView.selectedRow(inComponent: 1)]
        }
        
        if sectionForPicker == 1{
            destinationTodo = todos[typePickerView.selectedRow(inComponent: 0)]
            destinationAddress = places[typePickerView.selectedRow(inComponent: 1)]
        }
        
        self.tableView.reloadData()
    }
    
    func removePicker(){
        if let tag = self.view.viewWithTag(1){
            tag.removeFromSuperview()
        }
        
        self.navigationController?.isToolbarHidden = true
        
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? LeGuageResultViewController{
            vc.originPlace = originAddress
            vc.originTodo = originTodo
            
            vc.destinationTodo = destinationTodo
            vc.destinationPlace = destinationAddress
            
            vc.waypointTodos = waypointsTodo
            vc.waypointPlaces = waypointsPlace
            
            vc.travelOptions = travelOptions
        }
        
        if let vc = segue.destination as? LeGuageOptionsTableViewController{
            vc.delegate = self
        }
        
        if let vc = segue.destination as? LeGuageResultController{
            vc.originPlace = originAddress
            vc.originTodo = originTodo
            
            vc.destinationTodo = destinationTodo
            vc.destinationPlace = destinationAddress
            
            vc.waypointTodos = waypointsTodo
            vc.waypointPlaces = waypointsPlace
            
            vc.travelOptions = travelOptions
        }
    }
    
    
    func travelOptions(_ view: LeGuageOptionsTableViewController, didUpdateOptions options: [String : String]) {
        travelOptions = options
        
       // print("travel options delegate ", options)
    }
    
    func refreshData(){
        todos.removeAll()
        places.removeAll()
        waypointsPlace.removeAll()
        waypointsTodo.removeAll()
       // destinationTodo = nil
      //  destinationAddress = nil
       // originTodo = nil
       // originAddress = nil
        
        tableView.reloadData()
    }

}
