//
//  UITextViewExtension.swift
//  FPCDynamicForm
//
//  Created by 陳仲堯 on 2022/5/18.
//  Copyright © 2022 陳仲堯. All rights reserved.
//

import UIKit

class VerticallyCenteredTextView: UITextView {

    override func layoutSubviews() {
        super.layoutSubviews()
    
        let rect = layoutManager.usedRect(for: textContainer)
        let topInset = (bounds.size.height - rect.height) / 2.0
        textContainerInset.top = max(0, topInset)
    }
}
