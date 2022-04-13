//
//  DFTableCell.swift
//  Test10
//
//  Created by 陳仲堯 on 2022/4/12.
//  Copyright © 2022 陳仲堯. All rights reserved.
//

import UIKit

class DFTableCell: UITableViewCell {

    @IBOutlet weak var key1: UITextView!
    @IBOutlet weak var key2: UITextView!
    @IBOutlet weak var key3: UITextView!
    @IBOutlet weak var key4: UITextView!
    @IBOutlet weak var key5: UITextView!
    @IBOutlet weak var key6: UITextView!
    @IBOutlet weak var key7: UITextView!
    @IBOutlet weak var key8: UITextView!
    @IBOutlet weak var key9: UITextView!
    @IBOutlet weak var key10: UITextView!
    
    @IBOutlet weak var keyWidth1: NSLayoutConstraint!
    @IBOutlet weak var keyWidth2: NSLayoutConstraint!
    @IBOutlet weak var keyWidth3: NSLayoutConstraint!
    @IBOutlet weak var keyWidth4: NSLayoutConstraint!
    @IBOutlet weak var keyWidth5: NSLayoutConstraint!
    @IBOutlet weak var keyWidth6: NSLayoutConstraint!
    @IBOutlet weak var keyWidth7: NSLayoutConstraint!
    @IBOutlet weak var keyWidth8: NSLayoutConstraint!
    @IBOutlet weak var keyWidth9: NSLayoutConstraint!
    @IBOutlet weak var keyWidth10: NSLayoutConstraint!
    
    @IBOutlet weak var keyHeight1: NSLayoutConstraint!
    @IBOutlet weak var keyHeight2: NSLayoutConstraint!
    @IBOutlet weak var keyHeight3: NSLayoutConstraint!
    @IBOutlet weak var keyHeight4: NSLayoutConstraint!
    @IBOutlet weak var keyHeight5: NSLayoutConstraint!
    @IBOutlet weak var keyHeight6: NSLayoutConstraint!
    @IBOutlet weak var keyHeight7: NSLayoutConstraint!
    @IBOutlet weak var keyHeight8: NSLayoutConstraint!
    @IBOutlet weak var keyHeight9: NSLayoutConstraint!
    @IBOutlet weak var keyHeight10: NSLayoutConstraint!
    
    @IBOutlet weak var keyGap1: NSLayoutConstraint!
    @IBOutlet weak var keyGap2: NSLayoutConstraint!
    @IBOutlet weak var keyGap3: NSLayoutConstraint!
    @IBOutlet weak var keyGap4: NSLayoutConstraint!
    @IBOutlet weak var keyGap5: NSLayoutConstraint!
    @IBOutlet weak var keyGap6: NSLayoutConstraint!
    @IBOutlet weak var keyGap7: NSLayoutConstraint!
    @IBOutlet weak var keyGap8: NSLayoutConstraint!
    @IBOutlet weak var keyGap9: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        keyWidth1.constant = 0
        keyWidth2.constant = 0
        keyWidth3.constant = 0
        keyWidth4.constant = 0
        keyWidth5.constant = 0
        keyWidth6.constant = 0
        keyWidth7.constant = 0
        keyWidth8.constant = 0
        keyWidth9.constant = 0
        keyWidth10.constant = 0
        
        keyGap1.constant = 0
        keyGap2.constant = 0
        keyGap3.constant = 0
        keyGap4.constant = 0
        keyGap5.constant = 0
        keyGap6.constant = 0
        keyGap7.constant = 0
        keyGap8.constant = 0
        keyGap9.constant = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        key1.text = ""
        key2.text = ""
        key3.text = ""
        key4.text = ""
        key5.text = ""
        key6.text = ""
        key7.text = ""
        key8.text = ""
        key9.text = ""
        key10.text = ""
        
        keyWidth1.constant = 0
        keyWidth2.constant = 0
        keyWidth3.constant = 0
        keyWidth4.constant = 0
        keyWidth5.constant = 0
        keyWidth6.constant = 0
        keyWidth7.constant = 0
        keyWidth8.constant = 0
        keyWidth9.constant = 0
        keyWidth10.constant = 0
        
        keyHeight1.constant = 40
        keyHeight2.constant = 40
        keyHeight3.constant = 40
        keyHeight4.constant = 40
        keyHeight5.constant = 40
        keyHeight6.constant = 40
        keyHeight7.constant = 40
        keyHeight8.constant = 40
        keyHeight9.constant = 40
        keyHeight10.constant = 40
        
        key1.inputAccessoryView = nil
        key1.inputView = nil
        
        key2.inputAccessoryView = nil
        key2.inputView = nil
        
        key3.inputAccessoryView = nil
        key3.inputView = nil
        
        key4.inputAccessoryView = nil
        key4.inputView = nil
        
        key5.inputAccessoryView = nil
        key5.inputView = nil
        
        key6.inputAccessoryView = nil
        key6.inputView = nil
        
        key7.inputAccessoryView = nil
        key7.inputView = nil
        
        key8.inputAccessoryView = nil
        key8.inputView = nil
        
        key9.inputAccessoryView = nil
        key9.inputView = nil
        
        key10.inputAccessoryView = nil
        key10.inputView = nil
        
        for gesture in key1.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key1.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key2.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key2.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key3.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key3.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key4.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key4.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key5.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key5.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key6.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key6.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key7.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key7.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key8.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key8.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key9.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key9.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key10.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key10.removeGestureRecognizer(g)
            }
        }
    }
    
}
