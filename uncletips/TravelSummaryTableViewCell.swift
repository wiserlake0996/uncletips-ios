//
//  TravelSummaryTableViewCell.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 6/22/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import UIKit

class TravelSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var travelModesLabel: UILabel!
    @IBOutlet weak var totalTimeAllocatedLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
