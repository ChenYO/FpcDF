//
//  DFElecSignVC.swift
//  FPCDynamicForm
//
//  Created by 陳仲堯 on 2022/3/30.
//  Copyright © 2022 陳仲堯. All rights reserved.
//

import UIKit

class DFElecSignVC: UIViewController {
    
    @IBOutlet weak var drawingView: DFDrawingView!
    @IBOutlet weak var tipLabel: UILabel!
    
    var signatureExport: UIImage?
    var imageView: UIImageView?
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sendButton = UIBarButtonItem(title: DFLocalizable.valueOf(.DF_COMMAND_CONFIRM), style: UIBarButtonItem.Style.plain, target: self, action: #selector(send))
        
        let clearButton = UIBarButtonItem(title: DFLocalizable.valueOf(.DF_CLEAR), style: UIBarButtonItem.Style.plain, target: self, action: #selector(clear))
        
        //        sendButton.tintColor = .white
        //        clearButton.tintColor = .white
        
        self.navigationItem.rightBarButtonItems = [sendButton, clearButton]
        
        tipLabel.isHidden = true
        
//        self.view.makeToast(DFLocalizable.valueOf(.DF_SIGN_FAILED), duration: TimeInterval(1.0), position: CSToastPositionCenter)
        //        let tap: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(imageTaped))
        //
        //        drawingView!.addGestureRecognizer(tap)
    }
    
    @objc func imageTaped(sender: UISwipeGestureRecognizer) {
        let touchLocation: CGPoint = sender.location(in: sender.view)
        tipLabel.isHidden = true
        print(touchLocation)
    }
    
    
    func clearImage() {
        signatureExport = nil
        drawingView.clear()
        if let imageView = imageView {
            imageView.removeFromSuperview()
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        clearImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        clearImage()
    }
    
    
    @objc func send(sender: AnyObject) {
        if let imageView = imageView {
            imageView.removeFromSuperview()
        }
        
        signatureExport = drawingView.export()
        
        
        imageView = UIImageView(image: self.signatureExport)
        imageView!.frame = CGRect(x: 0, y: 100, width: signatureExport!.size.width, height: signatureExport!.size.height)
        imageView?.contentMode = .scaleAspectFit
        imageView?.backgroundColor = .white
        
        if let image = self.signatureExport?.rotateImageByOrientation().jpegData(compressionQuality: 0.9) {
            let signData = DFSignImages()
            signData.index = index
            signData.signImage = image
            
            DFUtil.elecSignImages.append(signData)
            
        }else {
            let alert = UIAlertController(title: DFLocalizable.valueOf(.MESSAGE_TIP), message: DFLocalizable.valueOf(.DF_SIGN_FAILED), preferredStyle: .alert)
            let confirm = UIAlertAction(title: DFLocalizable.valueOf(.DF_COMMAND_CONFIRM), style: .default)
            
            alert.addAction(confirm)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
        
        //        self.view.addSubview(imageView!)
        
        
    }
    
    @objc func clear(sender: AnyObject) {
        clearImage()
    }
    
}
