//
//  NotificationCell.swift
//  GoyoTeacher
//
//  Created by admin on 27/10/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet var date: UILabel!
    @IBOutlet var mainView: UIView!
    @IBOutlet var title: UILabel!
    @IBOutlet var message: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewDesign(view: mainView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
