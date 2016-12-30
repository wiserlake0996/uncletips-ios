//
//  TravelDetailsTableViewCell.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 6/22/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import UIKit

class TravelDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var todoLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var transitDetails: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
