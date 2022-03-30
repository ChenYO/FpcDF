//
//  DFSignCell.swift
//  FPCDynamicForm
//
//  Created by 陳仲堯 on 2022/3/30.
//  Copyright © 2022 陳仲堯. All rights reserved.
//

import UIKit

class DFSignCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var signImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
