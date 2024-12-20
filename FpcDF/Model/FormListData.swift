//
//  FormListData.swift
//  DynamicForm
//
//  Created by 陳仲堯 on 2019/11/25.
//  Copyright © 2019 陳仲堯. All rights reserved.
//

import UIKit

class FormListData: Codable {
    var versionCode: Int?
    var formVersion: Int?
    var formTitle: String?
    var formID: String?
    var formRandomID: String?
    var dataSourceUrl: String?
    var thirdInputUrl: String?
    var thirdOutputUrl: String?
    var thirdApproveUrl: String?
    var buttons: [button]
    var cells: [cell]
    var tip: String?
    var checkAllButton: Bool?
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
    var subCellDataList: [subCellData]?
    var dataSource: String?
    var paramType: String?
    var copyCellId: String?
    var copyId: String?
    var backgroundColor: String?
    
    var fileUrl: String?
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

class option: Codable {
    var id: String?
    var name: String?
    var color: String?
    var functionType: String?
    var tip: String?
    var otherRequireList: [String]?
    var checkAll: Bool?
    var isForceRequire: Bool?
    var isOtherOption: Bool?
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

struct param: Codable {
    var key: String?
    var value: String?
}

class subCellData: Codable {
    var id: String?
    var title: String?
    var subType: String?
    var width: Double?
    var cellHeight: Double?
    var cellGap: Double?
    var loopIndex: Int?
    var textValue: String?
    var options: [option]?
    var isHorizon: Bool?
    var isReserve: Bool?
    var isRequired: Bool?
    var isOptional: Bool?
    var extra1: String?
    var extra2: String?
    var extra3: String?
    var extra4: String?
    var extra5: String?
    var extra6: String?
    var extra7: String?
    var extra8: String?
    var subFormId: String?
    var dataSource: String?
    var paramType: String?
    var dataId: String?
    var searchId: String?
    var copyCellId: String?
    
    var height: CGFloat?
    var titleFont: font?
    var choiceValue: [String]?
    var keyBoardType: String?
    var borderColor: String?
    var finishColor: String?
    var isIncrement: Bool?
    var isBold: Bool?
    var isFirstCopyCell: Bool?
    var conditionID: String?
    var tip: String?
    var needConditionIdList: [String]?
    var isDefaultDate: Bool?
    var fixedMessage: String?
    var maxValue: Double?
    var minValue: Double?
    var overLimitColor: String?
    var needIndex: Bool?
    var canCheckAll: Bool?
    var checkNumber: Int?
    var isSignRemark: Bool?
    var signTip: String?
    var fontLimit: Int?
    var forceAnswerList: [param]?
    var emptyForceAnswerList: [param]?
    var hasForceAnswer: Bool?
    var relatedFormID: String?
    var hasRelateItem: String?
    var relateItem: String?
    var relateAnswer: String?
    var otherRequireList: [String]?
    var otherNotRequireList: [String]?
    var signAllId: String?
    var canInputFutureDate: Bool?
    var defaultAnswer: String?
    var isMultipleChoice: Bool?
    var optionAlignNumber: Int?
    
    var limitTextNeedTip: Bool?
    var limitTextCheckList: [String]?
    var limitTextPassList: [param]?
    var limitTextUnPassList: [param]?
    
    var backgroundColor: String?
    var isReadOnly: Bool?
    
    var fileUrl: String?
    var isFinish: Bool?
}
