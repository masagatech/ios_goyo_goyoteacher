//
//  AssignmentCell.swift
//  GoyoTeacher
//
//  Created by admin on 03/11/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit

class AssignmentCell: UITableViewCell {

    @IBOutlet var className: UILabel!
    @IBOutlet var assignsubject: UILabel!
    @IBOutlet var message: UILabel!
    @IBOutlet var todate: UILabel!
    @IBOutlet var fromdate: UILabel!
    @IBOutlet var assignmentTitle: UILabel!
    @IBOutlet var mainView: UIView!
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
