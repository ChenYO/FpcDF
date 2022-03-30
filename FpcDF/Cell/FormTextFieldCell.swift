//
//  FormTextFieldCell.swift
//  DynamicForm
//
//  Created by 陳仲堯 on 2019/11/25.
//  Copyright © 2019 陳仲堯. All rights reserved.
//

import UIKit

class FormTextFieldCell: UITableViewCell {

    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var deleteIcon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var constraint: NSLayoutConstraint?
    var imageConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        constraint = NSLayoutConstraint(item: title, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 21)
//        title.addConstraint(constraint!)
        
        imageConstraint = NSLayoutConstraint(item: deleteIcon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 0)
        deleteIcon.addConstraint(imageConstraint!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
