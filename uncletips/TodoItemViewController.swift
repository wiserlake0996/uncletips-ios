//
//  TodoItemViewController.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 5/22/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase
import Firebase

protocol TodoItemViewControllerDelegate:class{
    func todo(_ controller: TodoItemViewController, didUpdateTodoItem todo:Todo, place:Place, journey:Journey?)
}

class TodoItemViewController: UITableViewController, GoogleDistanceApiDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var preferenceLabel: UILabel!
    @IBOutlet weak var suggestionsSwitch: UISwitch!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    @IBOutlet weak var journeyLabel: UILabel!
    @IBOutlet weak var saveTodoButton: UIBarButtonItem!
    @IBOutlet weak var timeAllocationLabel: UITextField!
    
    //MARK: Properties
    var todo:Todo?
    var place:Place?
    var journey:Journey?
    var currentLocation: CLLocationCoordinate2D?
    
    var delegate:TodoItemViewControllerDelegate?
    
    var gda:GoogleDistanceApi = GoogleDistanceApi()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        gda.delegate = self
        displayTodoData()
        
        nameTextField.delegate = self
        timeAllocationLabel.delegate = self
        
        
        checkValidTodo()
        updateViewWithData()


    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshJourney()
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        if place?.type() != "todo"{
            let newPlace = TodoPlace(id: place!.id, name: place!.name, address: place!.address, lat: place!.lat, lng: place!.lng)
            newPlace.typeID = todo!.id
            
            newPlace.googlePlaceId = place?.googlePlaceId
            newPlace.icon = place?.icon
            newPlace.reference = place?.reference
            newPlace.categoryTypes = place?.categoryTypes
            newPlace.priceLevel = place?.priceLevel
            newPlace.openStatus = place?.openStatus
            newPlace.photos = place?.photos
            
            place = newPlace
            
        }
        
        
        DataService.sharedInstance.createNewTodo(saveObjectMake(todo!, place: place!))


        
       // if delegate != nil{
       //     delegate?.todo(self, didUpdateTodoItem: todo!, place: place!, journey: journey)
       // }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
            self.navigationController?.popViewController(animated: true)
    }
    //MARK: Methods
    
    func checkValidTodo() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        todo?.name = text
        saveTodoButton.isEnabled = !text.isEmpty
        
        if let text = timeAllocationLabel.text{
            
            if text != ""{
            todo?.settings.timeAllocation = Double(text)
            }
        }
    }
    
    func displayTodoData(){
        
        if let td = todo{
            nameTextField.text = td.name
        }
        
        if let pl = place{
            placeNameLabel.text = pl.name
            placeAddressLabel.text = pl.address
        }
        
        if let jou = journey{
            journeyLabel.text = jou.formattedJourney()
        }
 
    }
    
    func updateViewWithData()
    {
        preferenceLabel.text = "Preferences"
        var pref:String = ""
        if todo?.settings.locationEntry != nil || todo?.settings.locationExit != nil{
            pref += "location"
        }
        
        if todo?.settings.fixedTime != nil || todo?.settings.randomTime != nil{
            if pref == ""{
                pref += "Time"
            }else{
                pref += " & Time"
            }
        }
        preferenceLabel.text = pref
        
        if let all = todo?.settings.timeAllocation{
            timeAllocationLabel.text = "\(Int(all))"
        }
        
        
    }
    
    
    func refreshJourney(){
        
        if let curr = currentLocation{
            
            let origin  = "\(curr.latitude),\(curr.longitude)"
            let destination = "\(place!.lat),\(place!.lng)"

            journeyLabel.text = "refreshing journey data..."
            gda.requestDistanceWithDelegate(origin, destinations: destination)
        }
    }
    
    func updateView(_ text:String){
        journeyLabel.text = text
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "TodoSettingsPage"{

            if let vc = segue.destination as? TodoItemSettingsViewController{
                vc.delegate = self
                vc.settings = todo?.settings
            }
        }
        
    }
    
    @IBAction func viewSuggestions(_ sender: UIButton) {

    }
    
    
    func distanceApi(_ distanceApi: GoogleDistanceApi, distanceCalculationResponse data: [Journey]) {
        
        DispatchQueue.main.async(execute: {
 
            if data.count > 0{
                self.journey = data[0]
                self.updateView(self.journey!.formattedJourney())
            }else{
                self.journeyLabel.text = "journey unavailable"
            }
          
        })

    }

}


extension TodoItemViewController: TodoSettingsDelegate{
    
    func todo(_ controller: TodoItemSettingsViewController, settings: TodoSettings) {
        todo?.settings = settings
        updateViewWithData()
        
    }
}

extension TodoItemViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkValidTodo()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveTodoButton.isEnabled = false
    }
}
