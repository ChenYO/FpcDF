//
//  DynamicDelegate.swift
//  FPCDynamicForm
//
//  Created by 陳仲堯 on 2022/5/4.
//  Copyright © 2022 陳仲堯. All rights reserved.
//

import Foundation


public protocol DynamicDelegate {
    
    func dynamicSaveForm(_ formId: String, _ formStringList: [String])
}