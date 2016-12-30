//
//  SearchInfoWindow.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 5/31/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import UIKit

protocol UIViewLoading {}
extension UIView : UIViewLoading {}

class SearchInfoWindow: UIView {

    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    @IBOutlet weak var placeJourneyLabel: UILabel!
    
    override func didMoveToSuperview() {
        superview?.autoresizesSubviews = false
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "SearchInfoWindow", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    func setData(_ place:Place, journey:Journey?){
        placeNameLabel.text = place.name
        placeAddressLabel.text = place.address
        
        if let jou = journey{
            placeJourneyLabel.text = jou.formattedJourney()
            
        }else{
            placeJourneyLabel.text = "journey info (None)"
            
        }
    }

}
extension UIViewLoading where Self : UIView {
    
    // note that this method returns an instance of type `Self`, rather than UIView
    static func loadFromNib() -> Self {
        let nibName = "\(self)".characters.split{$0 == "."}.map(String.init).last!
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! Self
    }
}
