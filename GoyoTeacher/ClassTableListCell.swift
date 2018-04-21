//
//  ClassTableListCell.swift
//  GoyoTeacher
//
//  Created by admin on 25/10/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit

class ClassTableListCell: UITableViewCell {
    
    @IBOutlet var schoolLogo: UIImageView!
    @IBOutlet var mainView: UIView!
    @IBOutlet var className: UILabel!
    @IBOutlet var clsstrength: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        clsstrength.layer.cornerRadius = clsstrength.frame.width/2
        clsstrength.layer.masksToBounds = true
        
        schoolLogo.layer.cornerRadius = schoolLogo.frame.width/2
        schoolLogo.layer.masksToBounds = true
        
        viewDesign(view: mainView)
        
        }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
