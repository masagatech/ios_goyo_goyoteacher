//
//  HolidayTableViewCell.swift
//  GoyoParent
//
//  Created by admin on 21/09/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit


class HolidayTableViewCell: UITableViewCell {

    @IBOutlet var mainview: UIView!
    @IBOutlet var date: UILabel!
    @IBOutlet var holidayName: UILabel!
    @IBOutlet var holidayDesc: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainview.layer.borderColor = UIColor.white.cgColor
        mainview.layer.borderWidth = 1.0
        mainview.layer.cornerRadius = 5.0
        mainview.layer.shadowOpacity = 0.75
        mainview.layer.shadowOffset = CGSize(width: 0, height: 1)
        mainview.layer.shadowRadius = 0.3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
