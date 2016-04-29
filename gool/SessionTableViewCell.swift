//
//  SessionTableViewCell.swift
//  gool
//
//  Created by Janet on 4/29/16.
//  Copyright © 2016 Dead Squad. All rights reserved.
//

import UIKit

class SessionTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var sessionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
