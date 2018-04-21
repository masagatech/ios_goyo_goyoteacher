//
//  ResultExamDetailCell.swift
//  GoyoParent
//
//  Created by admin on 17/10/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit

class ResultExamDetailCell: FoldingCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    override func animationDuration(_ itemIndex: NSInteger, type: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }

//    @IBOutlet var circleprogress: CircleProgressBar!
}
