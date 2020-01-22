//
//  KeyValueCell.swift
//  DynamicForm
//
//  Created by 陳仲堯 on 2019/12/19.
//  Copyright © 2019 陳仲堯. All rights reserved.
//

import UIKit

class KeyValueCell: UITableViewCell {

    @IBOutlet weak var key: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var key2: UILabel!
    @IBOutlet weak var value2: UILabel!
    @IBOutlet weak var checkIcon: UIImageView!
    
    @IBOutlet weak var key2TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var value2TopConstraint: NSLayoutConstraint!
    
    var key2Constraint: NSLayoutConstraint?
    var value2Constraint: NSLayoutConstraint?
    
    var imageConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        key2Constraint = NSLayoutConstraint(item: key2, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: self.frame.width)
        key2.addConstraint(key2Constraint!)
//
//        value2Constraint = NSLayoutConstraint(item: value2, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 21)
//        value2.addConstraint(value2Constraint!)
        
        imageConstraint = NSLayoutConstraint(item: checkIcon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 0)
        checkIcon.addConstraint(imageConstraint!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
