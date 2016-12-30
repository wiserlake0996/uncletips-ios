//
//  TodoItemSettingsViewController.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 5/22/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import UIKit


protocol TodoSettingsDelegate: class{
    func todo(_ controller: TodoItemSettingsViewController, settings:TodoSettings)
    
}

class TodoItemSettingsViewController: UITableViewController {
    
    
    //MARK: Properties
    var settings:TodoSettings?
    
    var delegate:TodoSettingsDelegate?

    @IBOutlet weak var emailPreferenceLabel: UILabel!
    @IBOutlet weak var emailPreferenceSwitch: UISwitch!
    
    @IBOutlet weak var suggestSwitch: UISwitch!
    
    @IBOutlet weak var locationArrivalSwitch: UISwitch!
    @IBOutlet weak var locationExitSwitch: UISwitch!
    
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    
    @IBOutlet weak var randomTimeSwitch: UISwitch!
    @IBOutlet weak var customTimeSwitch: UISwitch!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDataToView()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        print(" away location exit: \(settings?.locationExit)")

        delegate?.todo(self, settings: settings!)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Methods
    
    func loadDataToView(){
        
        if let sett = settings{
            
            if let email = sett.notificationEmail{
                emailPreferenceLabel.text = "email set to \(email)"
                emailPreferenceSwitch.setOn(true, animated: true)
            }
            
            if let sugg = sett.suggestions{
                suggestSwitch.setOn(sugg, animated: true)
            }
            
            if let arrival = sett.locationEntry{
                locationArrivalSwitch.setOn(arrival, animated: true)
            }
            
            if let exit = sett.locationExit{
                locationExitSwitch.setOn(exit, animated: true)
            }
            
            
            radiusLabel.text = "radius: \(Int(sett.radius))m"
            radiusSlider.value = Float(sett.radius)
            
            
            if let randTime = sett.randomTime{
                randomTimeSwitch.setOn(true, animated: true)
                print (randTime)
            }
            
            if let fixedTime = sett.fixedTime{
                
                datePicker.isHidden = false
                datePicker.setDate(fixedTime as Date, animated: true)
                
                customTimeSwitch.setOn(true, animated: true)
                
            }
        }else{
            settings = TodoSettings()
        }
    }
    
    
    // MARK - Action Methods
    
    @IBAction func emailSwitchAction(_ sender: UISwitch) {
        if sender.isOn{
            
            if settings?.notificationEmail == nil || settings?.notificationEmail == ""{
                getEmailInput()
            }else{
                self.emailPreferenceLabel.text = "email set to \((settings?.notificationEmail))"
            }
        }else{
            self.emailPreferenceLabel.text = "email"
            settings?.notificationEmail = nil
            
        }
        
    }
    
    @IBAction func suggestSwitchAction(_ sender: UISwitch) {
        
        settings?.suggestions = Bool(sender.isOn)
        
        if !sender.isOn{
            settings?.suggestions = nil
        }
    }
    
    @IBAction func onEntrySwitchAction(_ sender: UISwitch) {
        settings?.locationEntry = Bool(sender.isOn)
        
        if !sender.isOn{
            settings?.locationEntry = nil
        }
    }
    
    @IBAction func onExitSwitchAction(_ sender: UISwitch) {
        settings?.locationExit = Bool(sender.isOn)
        
        if !sender.isOn{
            settings?.locationExit = nil
        }
        
        print("location exit: \(settings?.locationExit)")
    }

    @IBAction func radiusSliderAction(_ sender: UISlider) {
        settings?.radius = Double(sender.value)
        
        if let val = settings?.radius{
            radiusLabel.text = "radius: \(Int(val))m"
        }
        
        
    }
    
    @IBAction func randomTimeAction(_ sender: UISwitch) {
        
        if sender.isOn{
            let time = generateRandomInt(min: 600, max: 5000)
            settings?.randomTime = TimeInterval(time)
            showSimpleAlertWithTitle("Random time set", message: "random time: \(time/60) mins", viewController: self)
        }else{
            settings?.randomTime = nil
        }
        
    }
    
    
    @IBAction func fixedTimeAction(_ sender: UISwitch) {
        if sender.isOn{
            datePicker.isHidden = false
            settings?.fixedTime = datePicker.date
        }else{
            datePicker.isHidden = true
            settings?.fixedTime = nil
        }
    }
    
    @IBAction func datePickerAction(_ sender: UIDatePicker) {
        settings?.fixedTime = sender.date
        
        print (sender.date)
    }
    

    
    //MARK - METHODS
    
    func getEmailInput(){
        let alert = UIAlertController(title: "Set reminder email",
                                      message: "Enter an email address below",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default,
                                       handler: {
                                        (action:UIAlertAction) -> Void in
                                        
                                        let textField = alert.textFields!.first
                                        
                                        self.settings?.notificationEmail = (textField?.text!)!
                                        
                                        self.emailPreferenceLabel.text = "email set to \((textField?.text!)!)"
                                        
        })
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default) { (action: UIAlertAction) -> Void in
                                            self.emailPreferenceLabel.text = "email notifications"
                                            self.emailPreferenceSwitch.setOn(false, animated: true)
        }
        
        alert.addTextField {
            (textField: UITextField) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert,
                              animated: true,
                              completion: nil)
    }
    

}
