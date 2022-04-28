//
//  UIkitExtension.swift
//  DynamicForm
//
//  Created by 陳仲堯 on 2020/1/8.
//  Copyright © 2020 陳仲堯. All rights reserved.
//

import UIKit


extension UITextField {
    private struct AssociatedKey {
        static var cellIndex: Int = 0
        static var formNumber: Int = 0
        static var inputNumber: Int = 0
    }
    
    public var cellIndex: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.cellIndex) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.cellIndex, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var formNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.formNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.formNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var inputNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.inputNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.inputNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

extension UITextView {
    private struct AssociatedKey {
        static var index: Int = 0
        static var formNumber: Int = 0
        static var signleCellIndex: Int = 0
        static var signleInputIndex: Int = 0
        static var inputNumber: Int = 0
        static var width: CGFloat = 0.0
    }
    
    public var index: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.index) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.index, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var signleCellIndex: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.signleCellIndex) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.signleCellIndex, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var signleInputIndex: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.signleInputIndex) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.signleInputIndex, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var formNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.formNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.formNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var inputNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.inputNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.inputNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var width: CGFloat {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.width) as? CGFloat ?? 0.0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.width, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

extension UITapGestureRecognizer {
    private struct AssociatedKey {
        static var index: Int = 0
        static var formNumber: Int = 0
        static var cellNumber: Int = 0
        static var inputNumber: Int = 0
    }
    
    public var index: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.index) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.index, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var formNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.formNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.formNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var cellNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.cellNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.cellNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var inputNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.inputNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.inputNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

extension UIImagePickerController {
    private struct AssociatedKey {
        static var formNumber: Int = 0
        static var cellNumber: Int = 0
    }
    
    public var formNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.formNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.formNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var cellNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.cellNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.cellNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

extension UIDocumentMenuViewController {
    private struct AssociatedKey {
        static var formNumber: Int = 0
        static var cellNumber: Int = 0
    }
    
    public var formNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.formNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.formNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var cellNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.cellNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.cellNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

extension UIDocumentPickerViewController {
    private struct AssociatedKey {
        static var formNumber: Int = 0
        static var cellNumber: Int = 0
    }
    
    public var formNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.formNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.formNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var cellNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.cellNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.cellNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

extension UIBarButtonItem {
    private struct AssociatedKey {
        static var index: Int = 0
        static var formNumber: Int = 0
        static var inputNumber: Int = 0
    }
    
    public var index: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.index) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.index, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var formNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.formNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.formNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var inputNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.inputNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.inputNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

extension UIImageView {
    private struct AssociatedKey {
        static var formNumber: Int = 0
        static var cellNumber: Int = 0
        static var inputNumber: Int = 0
    }
    
    public var formNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.formNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.formNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var cellNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.cellNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.cellNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    public var inputNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.inputNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.inputNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
