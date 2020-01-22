//
//  AttachmentCell.swift
//  DynamicForm
//
//  Created by 陳仲堯 on 2019/12/11.
//  Copyright © 2019 陳仲堯. All rights reserved.
//

import UIKit

class fileCell: UITableViewCell {

    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var deleteIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
