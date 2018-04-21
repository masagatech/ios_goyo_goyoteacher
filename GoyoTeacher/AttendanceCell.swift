//
//  AttendanceCell.swift
//  GoyoTeacher
//
//  Created by admin on 25/10/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit

class AttendanceCell: UITableViewCell {
    
    //Attendance Section
    @IBOutlet var attendanceName: UILabel!
    @IBOutlet var sectionImage: UIImageView!
    
    
    //Cass Attendance
    @IBOutlet var mainViewHeight: NSLayoutConstraint!
    @IBOutlet var remark: UILabel!
    @IBOutlet var present: UISwitch!
    @IBOutlet var leave: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var rollNumber: UILabel!
    @IBOutlet var mainView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
     viewDesign(view: mainView)
        mainView.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        self.present.isOn = false
//    }
}
