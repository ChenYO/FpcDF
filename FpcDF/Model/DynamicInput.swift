//
//  MultiSelection.swift
//  DynamicForm
//
//  Created by 陳仲堯 on 2019/12/13.
//  Copyright © 2019 陳仲堯. All rights reserved.
//

import Foundation

class DynamicInput: Codable {
    var id: String?
    var name: String?
    var isSelected: Bool?
    var keyValueArray: [keyValue]? = []
    var jsonString: String?
}
