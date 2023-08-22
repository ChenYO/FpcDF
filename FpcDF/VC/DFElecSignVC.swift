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
    
    @IBOutlet weak var signImageView: UIImageView!
    @IBOutlet weak var signTip: UILabel!
    
    var signatureExport: UIImage?
    var imageView: UIImageView?
    var index = 0
    var formNumber = 0
    var cellIndex = 0
    var subCellIndex = 0
    var signImage: Data?
    var isFromSubCell = false
    var signUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sendButton = UIBarButtonItem(title: "確認", style: UIBarButtonItem.Style.plain, target: self, action: #selector(send))
        
        let clearButton = UIBarButtonItem(title: "清除", style: UIBarButtonItem.Style.plain, target: self, action: #selector(clear))
        
        //        sendButton.tintColor = .white
        //        clearButton.tintColor = .white
        
        self.navigationItem.rightBarButtonItems = [sendButton, clearButton]
        
        tipLabel.isHidden = true
        
        if signUrl != "" {
            
            drawingView.isHidden = true
            let fileURL = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!).appendingPathComponent(signUrl)
            if let imageData = NSData(contentsOf: fileURL!) {
                let image = UIImage(data: imageData as Data)
                
                self.signImageView.image = image
            }
        }else {
            self.signImageView.isHidden = true
            self.signTip.isHidden = true
        }
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
        
        if self.signUrl != "" {
            drawingView.isHidden = false
            signTip.isHidden = true
            self.signUrl = ""
            if let imageView = signImageView {
                imageView.removeFromSuperview()
            }

        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        clearImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        clearImage()
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

            
//            if !isFromSubCell {
//                self.signImage = image
//            }else {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                // choose a name for your image
                let fileName = "\(UUID().uuidString).jpg"
                // create the destination file url to save your image
                let fileURL = documentsDirectory.appendingPathComponent(fileName)
                
                print(fileURL)
                self.signUrl = fileName
                do {


                    try image.write(to: fileURL)
                    print("file saved")
                    
                    self.performSegue(withIdentifier: "toFormVC", sender: nil)
                    
                } catch {
                    print("error saving file:", error)
                    
                    let alert = UIAlertController(title: "訊息提示", message: "簽名檔儲存失敗", preferredStyle: .alert)
                    let confirm = UIAlertAction(title: "確認", style: .default)
                    
                    alert.addAction(confirm)
                    
                    self.present(alert, animated: true, completion: nil)
                }
//            }
            
            
            
        }else {
            let alert = UIAlertController(title: "訊息提示", message: "請簽名", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "確認", style: .default)
            
            alert.addAction(confirm)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
        
        //        self.view.addSubview(imageView!)
        
        
    }
    
    @objc func clear(sender: AnyObject) {
        clearImage()
    }
    
}
