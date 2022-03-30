//
//  FormListData.swift
//  DynamicForm
//
//  Created by 陳仲堯 on 2019/11/25.
//  Copyright © 2019 陳仲堯. All rights reserved.
//

import Foundation

class FormListData: Codable {
    var versionCode: Int?
    var formTitle: String?
    var formId: String?
    var buttons: [button]
    var cells: [cell]
}

struct button: Codable {
    var name: String?
    var url: String?
    var type: String?
    var actionTip: String?
    var actions: [action]?
}

class cell: Codable {
    var id: String?
    var type: String?
    var required: Bool?
    var isShowTip: Bool?
    var isReadOnly: Bool?
    var isRequired: Bool?
    var tip: String?
    var iconURL: String?
    var count: Int?
    var actionTip: String?
    var actions: [action]?
    var title: String?
    var titleFont: font?
    var keyValueArray: [keyValue]?
    var inputConfig: inputConfig?
    var options: [option]?
    var optionFont: font?
    var inputValue: String?
    var textValue: String?
    var choiceValue: [Int]?
    var dynamicField: [DynamicInput]?
    var fileList: [file]?
    var groupId: String?
    var groupItemId: String?
}

struct action: Codable {
    var actionType: String?
    var title: String?
    var url: String?
}

struct url: Codable {
    var title: String?
    var url: String?
}

struct font: Codable {
    var size: Int?
    var color: String?
    var alignment: String?
}

struct option: Codable {
    var id: String?
    var name: String?
}

struct inputConfig: Codable {
    var placeholder: String?
    var alignment: String?
    var limit: Int?
    var type: String?
}

//class dynamicInput: Codable {
//    var id: String?
//    var name: String?
//    var isSelected: Bool?
//    var keyValueArray: [keyValue]?
//    var jsonString: String?
//}

struct keyValue: Codable {
    var title: String?
    var size: Int?
    var color: String?
}

struct file: Codable {
    var type: String?
    var title: String?
    var url: String?
}
