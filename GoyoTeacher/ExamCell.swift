//
//  ExamCell.swift
//  GoyoTeacher
//
//  Created by admin on 02/11/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit

class ExamCell: UITableViewCell {

    @IBOutlet var date: UILabel!
    @IBOutlet var semsterName: UILabel!
    @IBOutlet var semsterCount: UILabel!
    @IBOutlet var mainView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewDesign(view: mainView)
        
        semsterCount.layer.cornerRadius = semsterCount.frame.height/2
        semsterCount.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
