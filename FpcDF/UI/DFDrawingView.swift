//
//  DFDrawingView.swift
//  FPCDynamicForm
//
//  Created by 陳仲堯 on 2022/3/30.
//  Copyright © 2022 陳仲堯. All rights reserved.
//

import UIKit

class DFDrawingView: UIView {
    
    var drawColor = UIColor.systemBlue
    var lineWidth: CGFloat = 5
    
    private var lastPoint: CGPoint!
    private var bezierPath: UIBezierPath!
    private var pointCounter: Int = 0
    private let pointLimit: Int = 128
    private var preRenderImage: UIImage!
    private var xArray: [CGFloat] = []
    private var yArray: [CGFloat] = []
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initBezierPath()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initBezierPath()
    }
    
    func initBezierPath() {
        bezierPath = UIBezierPath()
        bezierPath.lineCapStyle = CGLineCap.round
        bezierPath.lineJoinStyle = CGLineJoin.round
    }
    
    // MARK: - Touch handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: AnyObject? = touches.first
        lastPoint = touch!.location(in: self)
        pointCounter = 0
        xArray.append(lastPoint.x)
        yArray.append(lastPoint.y)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: AnyObject? = touches.first
        let newPoint = touch!.location(in: self)
        
        xArray.append(newPoint.x)
        yArray.append(newPoint.y)
        
        bezierPath.move(to: lastPoint)
        bezierPath.addLine(to: newPoint)
        lastPoint = newPoint
        
        pointCounter += 1
        
        if pointCounter == pointLimit {
            pointCounter = 0
            renderToImage()
            setNeedsDisplay()
            bezierPath.removeAllPoints()
        }
        else {
            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        pointCounter = 0
        renderToImage()
        setNeedsDisplay()
        bezierPath.removeAllPoints()
        
        let touch: AnyObject? = touches.first
        let newPoint = touch!.location(in: self)
        xArray.append(newPoint.x)
        yArray.append(newPoint.y)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        touchesEnded(touches!, with: event)
    }
    
    // MARK: - Pre render
    
    func renderToImage() {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        if preRenderImage != nil {
            preRenderImage.draw(in: self.bounds)
        }
        
        bezierPath.lineWidth = lineWidth
        drawColor.setFill()
        drawColor.setStroke()
        bezierPath.stroke()
        
        preRenderImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    // MARK: - Render
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if preRenderImage != nil {
            preRenderImage.draw(in: self.bounds)
        }
        
        bezierPath.lineWidth = lineWidth
        drawColor.setFill()
        drawColor.setStroke()
        bezierPath.stroke()
    }

    // MARK: - Clearing
    
    func clear() {
        preRenderImage = nil
        bezierPath.removeAllPoints()
        xArray = []
        yArray = []
        setNeedsDisplay()
    }
    
    // MARK: - Other
    func hasLines() -> Bool {
        return preRenderImage != nil || !bezierPath.isEmpty
    }

    
    
    func export() -> UIImage {
//        let minX = xArray.min()
//        let maxX = xArray.max()
//        let minY = yArray.min()
//        let maxY = yArray.max()

        if let minX = xArray.min(), let maxX = xArray.max(), let minY = yArray.min(), let maxY = yArray.max() {
            let width = (maxX - minX) == 0 ? 1 : (maxX - minX) + 5
            let height = (maxY - minY) == 0 ? 1 : (maxY - minY) + 5

            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0);

            preRenderImage.draw(at: CGPoint(x: -minX + 1, y: -minY + 3))
            preRenderImage = UIGraphicsGetImageFromCurrentImageContext()

            UIGraphicsEndImageContext()
            
            return preRenderImage
        }
        
        
        return UIImage()
        
    }
    
    func saveImage(image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("fileName.png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
}
