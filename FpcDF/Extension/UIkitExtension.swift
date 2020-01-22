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
        static var inputNumber: Int = 0
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
        static var inputNumber: Int = 0
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

extension UITapGestureRecognizer {
    private struct AssociatedKey {
        static var inputNumber: Int = 0
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
    }
    
    public var formNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.formNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.formNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

extension UIDocumentMenuViewController {
    private struct AssociatedKey {
        static var formNumber: Int = 0
    }
    
    public var formNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.formNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.formNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

extension UIDocumentPickerViewController {
    private struct AssociatedKey {
        static var formNumber: Int = 0
    }
    
    public var formNumber: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.formNumber) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.formNumber, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

