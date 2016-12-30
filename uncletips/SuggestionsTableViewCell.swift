//
//  SuggestionsTableViewCell.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 5/22/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import UIKit

class SuggestionsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
