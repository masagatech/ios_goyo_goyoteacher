//
//  ContentListCell.swift
//  GoyoTeacher
//
//  Created by admin on 15/12/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit

class ContentListCell: UITableViewCell {
    @IBOutlet var mainView: UIView!
    @IBOutlet var subjname: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewDesign(view: mainView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
