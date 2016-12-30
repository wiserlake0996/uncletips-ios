//
//  WaypointTableViewCell.swift
//  uncletips
//
//  Created by Ibrahim Dawha on 6/9/16.
//  Copyright © 2016 wiserlake. All rights reserved.
//

import UIKit

class WaypointTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
