//
//  timetableCell.swift
//  GoyoTeacher
//
//  Created by admin on 08/11/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit

class timetableCell: UITableViewCell {

    @IBOutlet var className: UILabel!
    @IBOutlet var mainView: UIView!
    @IBOutlet var subject: UILabel!
    @IBOutlet var timeings: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
