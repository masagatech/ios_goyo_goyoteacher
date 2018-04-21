//
//  ContentDetailsCell.swift
//  GoyoParent
//
//  Created by admin on 13/12/17.
//  Copyright © 2017 Goyo Tech Pvt Ltd. All rights reserved.
//

import UIKit

protocol ContentDetailsCellDelegate {
    func ContentDetailsCellPdfAction(_sender: ContentDetailsCell)
}
class ContentDetailsCell: UITableViewCell {

    @IBOutlet var mainView: UIView!
    @IBOutlet var status: UILabel!
    @IBOutlet var subjectpdf: UIButton!
    @IBOutlet var subjecTopic: UILabel!
    @IBOutlet var subjectName: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
     var delegate : ContentDetailsCellDelegate?
    @IBAction func downloadPdf(_ sender: Any) {
        delegate?.ContentDetailsCellPdfAction(_sender: self)
    }
    
}
