//
//  TodoInfoWindow.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 5/22/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import UIKit

class TodoInfoWindow: UIView {

    @IBOutlet weak var todoName: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationAddress: UILabel!
    @IBOutlet weak var journey: UILabel!
    @IBOutlet weak var timedReminders: UILabel!
    @IBOutlet weak var locationReminders: UILabel!
    @IBOutlet weak var suggestions: UILabel!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func didMoveToSuperview() {
        superview?.autoresizesSubviews = false
    }

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "TodoInfoWIndow", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    func setData(_ todo:Todo, place:Place, journeyData:Journey?){
        todoName.text = todo.name
                
        if todo.settings.fixedTime == nil && todo.settings.randomTime == nil{
            timedReminders.text = "time (Off)"
        }else{
            timedReminders.text = "time (On)"
        }
                
                
        if todo.settings.locationExit == nil && todo.settings.locationEntry == nil{
            locationReminders.text = "location (Off)"
        }else{
            locationReminders.text = "location (On)"
        }
                

        locationName.text = place.name
        locationAddress.text = place.address
                
        
        if let jou = journeyData{
            journey.text = jou.formattedJourney()
        }else{
            journey.text = "no journey info"
        }
            
    }
    
}
