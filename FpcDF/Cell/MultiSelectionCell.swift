//
//  MultiSelectionCell.swift
//  DynamicForm
//
//  Created by 陳仲堯 on 2019/12/13.
//  Copyright © 2019 陳仲堯. All rights reserved.
//

import UIKit

class MultiSelectionCell: UITableViewCell {

    @IBOutlet weak var option: UILabel!
    @IBOutlet weak var checkIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
