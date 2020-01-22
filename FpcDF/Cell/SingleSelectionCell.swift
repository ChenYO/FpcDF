//
//  SingleSelectionCell.swift
//  DynamicForm
//
//  Created by 陳仲堯 on 2019/12/12.
//  Copyright © 2019 陳仲堯. All rights reserved.
//

import UIKit

class SingleSelectionCell: UITableViewCell {

    @IBOutlet weak var actionTip: UILabel!
    @IBOutlet weak var optionTitle: UILabel!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var constraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        constraint = NSLayoutConstraint(item: actionTip, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 16)
        actionTip.addConstraint(constraint!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
