//
//  teacherleavecell.swift
//  GoyoTeacher
//
//  Created by admin on 04/11/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit

class teacherleavecell: UITableViewCell {

    @IBOutlet var applydate: UILabel!
    @IBOutlet var reason: UILabel!
    @IBOutlet var todate: UILabel!
    @IBOutlet var fromdate: UILabel!
    @IBOutlet var leaveType: UILabel!
    @IBOutlet var mainview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewDesign(view: mainview)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
