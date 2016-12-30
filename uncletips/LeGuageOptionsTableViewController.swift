//
//  LeGuageOptionsTableViewController.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 6/16/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import UIKit

protocol LeGuageOptionsDelegate:class{
    func travelOptions(_ view: LeGuageOptionsTableViewController, didUpdateOptions options:[String:String])
}

class LeGuageOptionsTableViewController: UITableViewController {

    @IBOutlet weak var timePreference: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var travelMode: UISegmentedControl!
    
    var travelOptions = [String:String]()
    
    let trafficOptions = ["optimistic","best_guess","pessimistic"]
    
    var delegate:LeGuageOptionsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if indexPath.section == 2{
            if let oldIndex = tableView.indexPathForSelectedRow {
            
                tableView.cellForRow(at: oldIndex)?.accessoryType = .none
            
            }
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        return indexPath
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let yourDate: Date = datePicker.date
        //now in this example
        let epochTimestamp: TimeInterval = yourDate.timeIntervalSince1970
        let epochTimestampString: String = String(Int(epochTimestamp))
        
        if timePreference.selectedSegmentIndex == 0{
            travelOptions["departure_time"] = epochTimestampString
        }else{
            travelOptions["arrival_time"] = epochTimestampString
        }
        
        if travelMode.selectedSegmentIndex == 0{
            travelOptions["mode"] = "driving"
        }else{
            travelOptions["mode"] = "transit"
        }
        
        if let index = tableView.indexPathForSelectedRow{
            travelOptions["traffic_model"] = trafficOptions[index.row]
        }
        
        if delegate != nil{
            delegate?.travelOptions(self, didUpdateOptions: travelOptions)
        }
        
        print (urlEncodeOptions(travelOptions))
    }

}
