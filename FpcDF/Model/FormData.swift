//
//  FormData.swift
//  DynamicForm
//
//  Created by 陳仲堯 on 2019/11/25.
//  Copyright © 2019 陳仲堯. All rights reserved.
//

import UIKit

class FormData {
    var mainType: String?
    var formType: String?
    var index: Int?
    var formNumber: Int?
    var cellNumber: Int?
    var formId: String?
    
    var isReadOnly: Bool?
    var isRequired: Bool?
    var isOptional: Bool?
    
    var inputNumber: Int?
    
    var actionTip: String?
    var actions: [action]?
    
    var title: String?
    
    var keyValueArray: [keyValue]?
    var valueString: String?
    
    var optionId: String?
    var optionNumber: Int?
    var optionValue: [Int]?
    
    var inputValue:String?
    
    var dynamicField: [DynamicInput]?
    var isCheck: Bool = false
    
    var image: UIImage?
    var fileUrl: String?
    
    var fileList: [file]?
    
    var subCellDataList: [subCellData]?
    
    var dateFormatterList = [dateFormatterObj]()
}
