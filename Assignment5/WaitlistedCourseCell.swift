//
//  WaitlistedCourseCell.swift
//  Assignment5
//
//  Created by Sydney Blackburn on 11/18/18.
//  Copyright © 2018 Sydney Blackburn. All rights reserved.
//

import UIKit

class WaitlistedCourseCell: UITableViewCell {
    
    @IBOutlet var subjectLabel: UILabel!
    @IBOutlet var courseNumLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var daysLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // adjusts cell size to font size set by user
        subjectLabel.adjustsFontForContentSizeCategory = true
        courseNumLabel.adjustsFontForContentSizeCategory = true
        timeLabel.adjustsFontForContentSizeCategory = true
        daysLabel.adjustsFontForContentSizeCategory = true
    }
}
