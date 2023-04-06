//
//  DFInputView.swift
//  Test10
//
//  Created by 陳仲堯 on 2023/4/6.
//  Copyright © 2023 陳仲堯. All rights reserved.
//

import UIKit

class DFInputView: UIView, DFNibOwnerLoadable {

    @IBOutlet weak var option: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    func loadXib(){
        
        loadNibContent()
        option.layer.borderWidth = 1
        option.layer.borderColor = UIColor(hexString: "#F0F0F0").cgColor
        
    }
}
