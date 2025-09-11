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
    @IBOutlet weak var key11: UITextView!
    @IBOutlet weak var key12: UITextView!
    @IBOutlet weak var key13: UITextView!
    @IBOutlet weak var key14: UITextView!
    @IBOutlet weak var key15: UITextView!
    @IBOutlet weak var key16: UITextView!
    @IBOutlet weak var key17: UITextView!
    @IBOutlet weak var key18: UITextView!
    @IBOutlet weak var key19: UITextView!
    @IBOutlet weak var key20: UITextView!
    @IBOutlet weak var key21: UITextView!
    @IBOutlet weak var key22: UITextView!
    @IBOutlet weak var key23: UITextView!
    @IBOutlet weak var key24: UITextView!
    @IBOutlet weak var key25: UITextView!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var imageView5: UIImageView!
    @IBOutlet weak var imageView6: UIImageView!
    @IBOutlet weak var imageView7: UIImageView!
    @IBOutlet weak var imageView8: UIImageView!
    @IBOutlet weak var imageView9: UIImageView!
    @IBOutlet weak var imageView10: UIImageView!
    @IBOutlet weak var imageView11: UIImageView!
    @IBOutlet weak var imageView12: UIImageView!
    @IBOutlet weak var imageView13: UIImageView!
    @IBOutlet weak var imageView14: UIImageView!
    @IBOutlet weak var imageView15: UIImageView!
    @IBOutlet weak var imageView16: UIImageView!
    @IBOutlet weak var imageView17: UIImageView!
    @IBOutlet weak var imageView18: UIImageView!
    @IBOutlet weak var imageView19: UIImageView!
    @IBOutlet weak var imageView20: UIImageView!
    @IBOutlet weak var imageView21: UIImageView!
    @IBOutlet weak var imageView22: UIImageView!
    @IBOutlet weak var imageView23: UIImageView!
    @IBOutlet weak var imageView24: UIImageView!
    @IBOutlet weak var imageView25: UIImageView!
    
    
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
    @IBOutlet weak var keyWidth11: NSLayoutConstraint!
    @IBOutlet weak var keyWidth12: NSLayoutConstraint!
    @IBOutlet weak var keyWidth13: NSLayoutConstraint!
    @IBOutlet weak var keyWidth14: NSLayoutConstraint!
    @IBOutlet weak var keyWidth15: NSLayoutConstraint!
    @IBOutlet weak var keyWidth16: NSLayoutConstraint!
    @IBOutlet weak var keyWidth17: NSLayoutConstraint!
    @IBOutlet weak var keyWidth18: NSLayoutConstraint!
    @IBOutlet weak var keyWidth19: NSLayoutConstraint!
    @IBOutlet weak var keyWidth20: NSLayoutConstraint!
    @IBOutlet weak var keyWidth21: NSLayoutConstraint!
    @IBOutlet weak var keyWidth22: NSLayoutConstraint!
    @IBOutlet weak var keyWidth23: NSLayoutConstraint!
    @IBOutlet weak var keyWidth24: NSLayoutConstraint!
    @IBOutlet weak var keyWidth25: NSLayoutConstraint!
    
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
    @IBOutlet weak var keyHeight11: NSLayoutConstraint!
    @IBOutlet weak var keyHeight12: NSLayoutConstraint!
    @IBOutlet weak var keyHeight13: NSLayoutConstraint!
    @IBOutlet weak var keyHeight14: NSLayoutConstraint!
    @IBOutlet weak var keyHeight15: NSLayoutConstraint!
    @IBOutlet weak var keyHeight16: NSLayoutConstraint!
    @IBOutlet weak var keyHeight17: NSLayoutConstraint!
    @IBOutlet weak var keyHeight18: NSLayoutConstraint!
    @IBOutlet weak var keyHeight19: NSLayoutConstraint!
    @IBOutlet weak var keyHeight20: NSLayoutConstraint!
    @IBOutlet weak var keyHeight21: NSLayoutConstraint!
    @IBOutlet weak var keyHeight22: NSLayoutConstraint!
    @IBOutlet weak var keyHeight23: NSLayoutConstraint!
    @IBOutlet weak var keyHeight24: NSLayoutConstraint!
    @IBOutlet weak var keyHeight25: NSLayoutConstraint!
    
    
    @IBOutlet weak var imageHeight1: NSLayoutConstraint!
    @IBOutlet weak var imageHeight2: NSLayoutConstraint!
    @IBOutlet weak var imageHeight3: NSLayoutConstraint!
    @IBOutlet weak var imageHeight4: NSLayoutConstraint!
    @IBOutlet weak var imageHeight5: NSLayoutConstraint!
    @IBOutlet weak var imageHeight6: NSLayoutConstraint!
    @IBOutlet weak var imageHeight7: NSLayoutConstraint!
    @IBOutlet weak var imageHeight8: NSLayoutConstraint!
    @IBOutlet weak var imageHeight9: NSLayoutConstraint!
    @IBOutlet weak var imageHeight10: NSLayoutConstraint!
    @IBOutlet weak var imageHeight11: NSLayoutConstraint!
    @IBOutlet weak var imageHeight12: NSLayoutConstraint!
    @IBOutlet weak var imageHeight13: NSLayoutConstraint!
    @IBOutlet weak var imageHeight14: NSLayoutConstraint!
    @IBOutlet weak var imageHeight15: NSLayoutConstraint!
    @IBOutlet weak var imageHeight16: NSLayoutConstraint!
    @IBOutlet weak var imageHeight17: NSLayoutConstraint!
    @IBOutlet weak var imageHeight18: NSLayoutConstraint!
    @IBOutlet weak var imageHeight19: NSLayoutConstraint!
    @IBOutlet weak var imageHeight20: NSLayoutConstraint!
    @IBOutlet weak var imageHeight21: NSLayoutConstraint!
    @IBOutlet weak var imageHeight22: NSLayoutConstraint!
    @IBOutlet weak var imageHeight23: NSLayoutConstraint!
    @IBOutlet weak var imageHeight24: NSLayoutConstraint!
    @IBOutlet weak var imageHeight25: NSLayoutConstraint!
    
    @IBOutlet weak var keyGap1: NSLayoutConstraint!
    @IBOutlet weak var keyGap2: NSLayoutConstraint!
    @IBOutlet weak var keyGap3: NSLayoutConstraint!
    @IBOutlet weak var keyGap4: NSLayoutConstraint!
    @IBOutlet weak var keyGap5: NSLayoutConstraint!
    @IBOutlet weak var keyGap6: NSLayoutConstraint!
    @IBOutlet weak var keyGap7: NSLayoutConstraint!
    @IBOutlet weak var keyGap8: NSLayoutConstraint!
    @IBOutlet weak var keyGap9: NSLayoutConstraint!
    @IBOutlet weak var keyGap10: NSLayoutConstraint!
    @IBOutlet weak var keyGap11: NSLayoutConstraint!
    @IBOutlet weak var keyGap12: NSLayoutConstraint!
    @IBOutlet weak var keyGap13: NSLayoutConstraint!
    @IBOutlet weak var keyGap14: NSLayoutConstraint!
    @IBOutlet weak var keyGap15: NSLayoutConstraint!
    @IBOutlet weak var keyGap16: NSLayoutConstraint!
    @IBOutlet weak var keyGap17: NSLayoutConstraint!
    @IBOutlet weak var keyGap18: NSLayoutConstraint!
    @IBOutlet weak var keyGap19: NSLayoutConstraint!
    @IBOutlet weak var keyGap20: NSLayoutConstraint!
    @IBOutlet weak var keyGap21: NSLayoutConstraint!
    @IBOutlet weak var keyGap22: NSLayoutConstraint!
    @IBOutlet weak var keyGap23: NSLayoutConstraint!
    @IBOutlet weak var keyGap24: NSLayoutConstraint!
    
    @IBOutlet weak var keyTop1: NSLayoutConstraint!
    @IBOutlet weak var keyTop2: NSLayoutConstraint!
    @IBOutlet weak var keyTop3: NSLayoutConstraint!
    @IBOutlet weak var keyTop4: NSLayoutConstraint!
    @IBOutlet weak var keyTop5: NSLayoutConstraint!
    @IBOutlet weak var keyTop6: NSLayoutConstraint!
    @IBOutlet weak var keyTop7: NSLayoutConstraint!
    @IBOutlet weak var keyTop8: NSLayoutConstraint!
    @IBOutlet weak var keyTop9: NSLayoutConstraint!
    @IBOutlet weak var keyTop10: NSLayoutConstraint!
    @IBOutlet weak var keyTop11: NSLayoutConstraint!
    @IBOutlet weak var keyTop12: NSLayoutConstraint!
    @IBOutlet weak var keyTop13: NSLayoutConstraint!
    @IBOutlet weak var keyTop14: NSLayoutConstraint!
    @IBOutlet weak var keyTop15: NSLayoutConstraint!
    @IBOutlet weak var keyTop16: NSLayoutConstraint!
    @IBOutlet weak var keyTop17: NSLayoutConstraint!
    @IBOutlet weak var keyTop18: NSLayoutConstraint!
    @IBOutlet weak var keyTop19: NSLayoutConstraint!
    @IBOutlet weak var keyTop20: NSLayoutConstraint!
    @IBOutlet weak var keyTop21: NSLayoutConstraint!
    @IBOutlet weak var keyTop22: NSLayoutConstraint!
    @IBOutlet weak var keyTop23: NSLayoutConstraint!
    @IBOutlet weak var keyTop24: NSLayoutConstraint!
    @IBOutlet weak var keyTop25: NSLayoutConstraint!
    
    @IBOutlet weak var ImageGap1: NSLayoutConstraint!
    @IBOutlet weak var ImageGap2: NSLayoutConstraint!
    @IBOutlet weak var ImageGap3: NSLayoutConstraint!
    @IBOutlet weak var ImageGap4: NSLayoutConstraint!
    @IBOutlet weak var ImageGap5: NSLayoutConstraint!
    @IBOutlet weak var ImageGap6: NSLayoutConstraint!
    @IBOutlet weak var ImageGap7: NSLayoutConstraint!
    @IBOutlet weak var ImageGap8: NSLayoutConstraint!
    @IBOutlet weak var ImageGap9: NSLayoutConstraint!
    @IBOutlet weak var ImageGap10: NSLayoutConstraint!
    @IBOutlet weak var ImageGap11: NSLayoutConstraint!
    @IBOutlet weak var ImageGap12: NSLayoutConstraint!
    @IBOutlet weak var ImageGap13: NSLayoutConstraint!
    @IBOutlet weak var ImageGap14: NSLayoutConstraint!
    @IBOutlet weak var ImageGap15: NSLayoutConstraint!
    @IBOutlet weak var ImageGap16: NSLayoutConstraint!
    @IBOutlet weak var ImageGap17: NSLayoutConstraint!
    @IBOutlet weak var ImageGap18: NSLayoutConstraint!
    @IBOutlet weak var ImageGap19: NSLayoutConstraint!
    @IBOutlet weak var ImageGap20: NSLayoutConstraint!
    @IBOutlet weak var ImageGap21: NSLayoutConstraint!
    @IBOutlet weak var ImageGap22: NSLayoutConstraint!
    @IBOutlet weak var ImageGap23: NSLayoutConstraint!
    @IBOutlet weak var ImageGap24: NSLayoutConstraint!
    

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!
    @IBOutlet weak var label8: UILabel!
    @IBOutlet weak var label9: UILabel!
    @IBOutlet weak var label10: UILabel!
    @IBOutlet weak var label11: UILabel!
    @IBOutlet weak var label12: UILabel!
    @IBOutlet weak var label13: UILabel!
    @IBOutlet weak var label14: UILabel!
    @IBOutlet weak var label15: UILabel!
    @IBOutlet weak var label16: UILabel!
    @IBOutlet weak var label17: UILabel!
    @IBOutlet weak var label18: UILabel!
    @IBOutlet weak var label19: UILabel!
    @IBOutlet weak var label20: UILabel!
    @IBOutlet weak var label21: UILabel!
    @IBOutlet weak var label22: UILabel!
    @IBOutlet weak var label23: UILabel!
    @IBOutlet weak var label24: UILabel!
    @IBOutlet weak var label25: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        key1.centerVerticalText()
//        key2.centerVerticalText()
//        key3.centerVerticalText()
//        key4.centerVerticalText()
//        key5.centerVerticalText()
//        key6.centerVerticalText()
//        key7.centerVerticalText()
//        key8.centerVerticalText()
        
        
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
        keyWidth11.constant = 0
        keyWidth12.constant = 0
        keyWidth13.constant = 0
        keyWidth14.constant = 0
        keyWidth15.constant = 0
        keyWidth16.constant = 0
        keyWidth17.constant = 0
        keyWidth18.constant = 0
        keyWidth19.constant = 0
        keyWidth20.constant = 0
        keyWidth21.constant = 0
        keyWidth22.constant = 0
        keyWidth23.constant = 0
        keyWidth24.constant = 0
        keyWidth25.constant = 0
        
        keyGap1.constant = 0
        keyGap2.constant = 0
        keyGap3.constant = 0
        keyGap4.constant = 0
        keyGap5.constant = 0
        keyGap6.constant = 0
        keyGap7.constant = 0
        keyGap8.constant = 0
        keyGap9.constant = 0
        keyGap10.constant = 0
        keyGap11.constant = 0
        keyGap12.constant = 0
        keyGap13.constant = 0
        keyGap14.constant = 0
        keyGap15.constant = 0
        keyGap16.constant = 0
        keyGap17.constant = 0
        keyGap18.constant = 0
        keyGap19.constant = 0
        keyGap20.constant = 0
        keyGap21.constant = 0
        keyGap22.constant = 0
        keyGap23.constant = 0
        keyGap24.constant = 0
        
        keyTop1.constant = 0
        keyTop2.constant = 0
        keyTop3.constant = 0
        keyTop4.constant = 0
        keyTop5.constant = 0
        keyTop6.constant = 0
        keyTop7.constant = 0
        keyTop8.constant = 0
        keyTop9.constant = 0
        keyTop10.constant = 0
        keyTop11.constant = 0
        keyTop12.constant = 0
        keyTop13.constant = 0
        keyTop14.constant = 0
        keyTop15.constant = 0
        keyTop16.constant = 0
        keyTop17.constant = 0
        keyTop18.constant = 0
        keyTop19.constant = 0
        keyTop20.constant = 0
        keyTop21.constant = 0
        keyTop22.constant = 0
        keyTop23.constant = 0
        keyTop24.constant = 0
        keyTop25.constant = 0
        
        ImageGap1.constant = 0
        ImageGap2.constant = 0
        ImageGap3.constant = 0
        ImageGap4.constant = 0
        ImageGap5.constant = 0
        ImageGap6.constant = 0
        ImageGap7.constant = 0
        ImageGap8.constant = 0
        ImageGap9.constant = 0
        ImageGap10.constant = 0
        ImageGap11.constant = 0
        ImageGap12.constant = 0
        ImageGap13.constant = 0
        ImageGap14.constant = 0
        ImageGap15.constant = 0
        ImageGap16.constant = 0
        ImageGap17.constant = 0
        ImageGap18.constant = 0
        ImageGap19.constant = 0
        ImageGap20.constant = 0
        ImageGap21.constant = 0
        ImageGap22.constant = 0
        ImageGap23.constant = 0
        ImageGap24.constant = 0
        
        imageHeight1.constant = 40
        imageHeight2.constant = 40
        imageHeight3.constant = 40
        imageHeight4.constant = 40
        imageHeight5.constant = 40
        imageHeight6.constant = 40
        imageHeight7.constant = 40
        imageHeight8.constant = 40
        imageHeight9.constant = 40
        imageHeight10.constant = 40
        imageHeight11.constant = 40
        imageHeight12.constant = 40
        imageHeight13.constant = 40
        imageHeight14.constant = 40
        imageHeight15.constant = 40
        imageHeight16.constant = 40
        imageHeight17.constant = 40
        imageHeight18.constant = 40
        imageHeight19.constant = 40
        imageHeight20.constant = 40
        imageHeight21.constant = 40
        imageHeight22.constant = 40
        imageHeight23.constant = 40
        imageHeight24.constant = 40
        imageHeight25.constant = 40
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
        key11.text = ""
        key12.text = ""
        key13.text = ""
        key14.text = ""
        key15.text = ""
        key16.text = ""
        key17.text = ""
        key18.text = ""
        key19.text = ""
        key20.text = ""
        key21.text = ""
        key22.text = ""
        key23.text = ""
        key24.text = ""
        key25.text = ""
        
        imageView1.image = nil
        imageView2.image = nil
        imageView3.image = nil
        imageView4.image = nil
        imageView5.image = nil
        imageView6.image = nil
        imageView7.image = nil
        imageView8.image = nil
        imageView9.image = nil
        imageView10.image = nil
        imageView11.image = nil
        imageView12.image = nil
        imageView13.image = nil
        imageView14.image = nil
        imageView15.image = nil
        imageView16.image = nil
        imageView17.image = nil
        imageView18.image = nil
        imageView19.image = nil
        imageView20.image = nil
        imageView21.image = nil
        imageView22.image = nil
        imageView23.image = nil
        imageView24.image = nil
        imageView25.image = nil
        
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
        keyWidth11.constant = 0
        keyWidth12.constant = 0
        keyWidth13.constant = 0
        keyWidth14.constant = 0
        keyWidth15.constant = 0
        keyWidth16.constant = 0
        keyWidth17.constant = 0
        keyWidth18.constant = 0
        keyWidth19.constant = 0
        keyWidth20.constant = 0
        keyWidth21.constant = 0
        keyWidth22.constant = 0
        keyWidth23.constant = 0
        keyWidth24.constant = 0
        keyWidth25.constant = 0
        
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
        keyHeight11.constant = 40
        keyHeight12.constant = 40
        keyHeight13.constant = 40
        keyHeight14.constant = 40
        keyHeight15.constant = 40
        keyHeight16.constant = 40
        keyHeight17.constant = 40
        keyHeight18.constant = 40
        keyHeight19.constant = 40
        keyHeight20.constant = 40
        keyHeight21.constant = 40
        keyHeight22.constant = 40
        keyHeight23.constant = 40
        keyHeight24.constant = 40
        keyHeight25.constant = 40
        
        imageHeight1.constant = 40
        imageHeight2.constant = 40
        imageHeight3.constant = 40
        imageHeight4.constant = 40
        imageHeight5.constant = 40
        imageHeight6.constant = 40
        imageHeight7.constant = 40
        imageHeight8.constant = 40
        imageHeight9.constant = 40
        imageHeight10.constant = 40
        imageHeight11.constant = 40
        imageHeight12.constant = 40
        imageHeight13.constant = 40
        imageHeight14.constant = 40
        imageHeight15.constant = 40
        imageHeight16.constant = 40
        imageHeight17.constant = 40
        imageHeight18.constant = 40
        imageHeight19.constant = 40
        imageHeight20.constant = 40
        imageHeight21.constant = 40
        imageHeight22.constant = 40
        imageHeight23.constant = 40
        imageHeight24.constant = 40
        imageHeight25.constant = 40
        
        
        keyGap1.constant = 0
        keyGap2.constant = 0
        keyGap3.constant = 0
        keyGap4.constant = 0
        keyGap5.constant = 0
        keyGap6.constant = 0
        keyGap7.constant = 0
        keyGap8.constant = 0
        keyGap9.constant = 0
        keyGap10.constant = 0
        keyGap11.constant = 0
        keyGap12.constant = 0
        keyGap13.constant = 0
        keyGap14.constant = 0
        keyGap15.constant = 0
        keyGap16.constant = 0
        keyGap17.constant = 0
        keyGap18.constant = 0
        keyGap19.constant = 0
        keyGap20.constant = 0
        keyGap21.constant = 0
        keyGap22.constant = 0
        keyGap23.constant = 0
        keyGap24.constant = 0
        
        keyTop1.constant = 0
        keyTop2.constant = 0
        keyTop3.constant = 0
        keyTop4.constant = 0
        keyTop5.constant = 0
        keyTop6.constant = 0
        keyTop7.constant = 0
        keyTop8.constant = 0
        keyTop9.constant = 0
        keyTop10.constant = 0
        keyTop11.constant = 0
        keyTop12.constant = 0
        keyTop13.constant = 0
        keyTop14.constant = 0
        keyTop15.constant = 0
        keyTop16.constant = 0
        keyTop17.constant = 0
        keyTop18.constant = 0
        keyTop19.constant = 0
        keyTop20.constant = 0
        keyTop21.constant = 0
        keyTop22.constant = 0
        keyTop23.constant = 0
        keyTop24.constant = 0
        keyTop25.constant = 0
        
        ImageGap1.constant = 0
        ImageGap2.constant = 0
        ImageGap3.constant = 0
        ImageGap4.constant = 0
        ImageGap5.constant = 0
        ImageGap6.constant = 0
        ImageGap7.constant = 0
        ImageGap8.constant = 0
        ImageGap9.constant = 0
        ImageGap10.constant = 0
        ImageGap11.constant = 0
        ImageGap12.constant = 0
        ImageGap13.constant = 0
        ImageGap14.constant = 0
        ImageGap15.constant = 0
        ImageGap16.constant = 0
        ImageGap17.constant = 0
        ImageGap18.constant = 0
        ImageGap19.constant = 0
        ImageGap20.constant = 0
        ImageGap21.constant = 0
        ImageGap22.constant = 0
        ImageGap23.constant = 0
        ImageGap24.constant = 0
        
        label1.isHidden = true
        label2.isHidden = true
        label3.isHidden = true
        label4.isHidden = true
        label5.isHidden = true
        label6.isHidden = true
        label7.isHidden = true
        label8.isHidden = true
        label9.isHidden = true
        label10.isHidden = true
        label11.isHidden = true
        label12.isHidden = true
        label13.isHidden = true
        label14.isHidden = true
        label15.isHidden = true
        label16.isHidden = true
        label17.isHidden = true
        label18.isHidden = true
        label19.isHidden = true
        label20.isHidden = true
        label21.isHidden = true
        label22.isHidden = true
        label23.isHidden = true
        label24.isHidden = true
        label25.isHidden = true
        
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
        
        key11.inputAccessoryView = nil
        key11.inputView = nil
        
        key12.inputAccessoryView = nil
        key12.inputView = nil
        
        key13.inputAccessoryView = nil
        key13.inputView = nil
        
        key14.inputAccessoryView = nil
        key14.inputView = nil
        
        key15.inputAccessoryView = nil
        key15.inputView = nil
        
        key16.inputAccessoryView = nil
        key16.inputView = nil
        
        key17.inputAccessoryView = nil
        key17.inputView = nil
        
        key18.inputAccessoryView = nil
        key18.inputView = nil
        
        key19.inputAccessoryView = nil
        key19.inputView = nil
        
        key20.inputAccessoryView = nil
        key20.inputView = nil
        
        key21.inputAccessoryView = nil
        key21.inputView = nil
        
        key22.inputAccessoryView = nil
        key22.inputView = nil
        
        key23.inputAccessoryView = nil
        key23.inputView = nil
        
        key24.inputAccessoryView = nil
        key24.inputView = nil
        
        key25.inputAccessoryView = nil
        key25.inputView = nil
        
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
        
        for gesture in key11.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key11.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key12.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key12.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key13.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key13.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key14.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key14.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key15.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key15.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key16.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key16.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key17.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key17.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key18.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key18.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key19.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key19.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key20.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key20.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key21.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key21.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key22.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key22.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key23.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key23.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key24.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key24.removeGestureRecognizer(g)
            }
        }
        
        for gesture in key25.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                key25.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView1.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView1.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView2.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView2.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView3.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView3.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView4.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView4.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView5.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView5.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView6.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView6.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView7.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView7.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView8.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView8.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView9.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView9.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView10.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView10.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView11.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView11.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView12.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView12.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView13.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView13.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView14.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView14.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView15.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView15.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView16.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView16.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView17.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView17.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView18.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView18.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView19.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView19.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView20.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView20.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView21.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView21.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView22.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView22.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView23.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView23.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView24.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView24.removeGestureRecognizer(g)
            }
        }
        
        for gesture in imageView25.gestureRecognizers ?? [] {
            if let g = gesture as? UITapGestureRecognizer {
                imageView25.removeGestureRecognizer(g)
            }
        }
        
    }
    
}
