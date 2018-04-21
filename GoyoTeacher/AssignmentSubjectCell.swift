//
//  AssignmentSubjectCell.swift
//  GoyoTeacher
//
//  Created by admin on 03/11/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit

class AssignmentSubjectCell: UITableViewCell {
    @IBOutlet var subjectname: UILabel!

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
