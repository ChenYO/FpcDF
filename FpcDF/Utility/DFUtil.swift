//
//  Util.swift
//  DynamicForm
//
//  Created by 陳仲堯 on 2019/12/20.
//  Copyright © 2019 陳仲堯. All rights reserved.
//

import Foundation
import UIKit

class DFUtil {
    
    static let versionCode = 2
    static let OSType = "iOS" // iOS, Android
    static let appRegion = "International" // International, China
    static var forceUpdateFlag = false
    static var tipUpdateFlag = false
    static var elecSignImages: [DFSignImages] = []
    
    static func decodeJsonStringAndReturnArrayObject<T: Decodable>(string: String, type: T.Type) throws -> [T] {
        let jsonData = string.data(using: .utf8)!
        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode([T].self, from: jsonData)
            return result
        } catch(let error) {
            print(error)
            throw ErrorType.JSONParseError
        }
    }
    
    static func decodeJsonStringAndReturnObject<T: Decodable>(string: String, type: T.Type) throws -> T {
        let jsonData = string.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        do {
            let result = try decoder.decode(T.self, from: jsonData)
            return result
        } catch {
            print(error)
            throw ErrorType.JSONParseError
        }
    }
    
    static func setKeyValueData(cell: KeyValueCell, keyValueArray: [keyValue]) {
        cell.key.text = ""
        cell.value.text = ""
        cell.key2.text = ""
        cell.value2.text = ""
        
        if let title = keyValueArray[0].title, title != "" {
            cell.key.text = title
        }
        
        if let title = keyValueArray[1].title, title != "" {
            cell.value.text = title
            cell.value.isHidden = false
        }else {
            cell.value.isHidden = true
        }
        
        if let title = keyValueArray[2].title, title != "" {
            cell.key2.text = title
            cell.key2TopConstraint?.constant = 5
        }else {
            cell.key2TopConstraint?.constant = 0
        }
        
        if let title = keyValueArray[3].title, title != "" {
            cell.value2.text = title
            cell.value2TopConstraint?.constant = 5
        }else {
            cell.value2TopConstraint?.constant = 0
        }
        
        if let fontSize = keyValueArray[0].size {
            cell.key.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        }
        if let fontColor = keyValueArray[0].color {
            cell.key.textColor = UIColor(hexString: fontColor)
        }
        if let fontSize = keyValueArray[1].size {
            cell.value.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        }
        if let fontColor = keyValueArray[1].color {
            cell.value.textColor = UIColor(hexString: fontColor)
        }
        if let fontSize = keyValueArray[2].size {
            cell.key2.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        }
        if let fontColor = keyValueArray[2].color {
            cell.key2.textColor = UIColor(hexString: fontColor)
        }
        if let fontSize = keyValueArray[3].size {
            cell.value2.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        }
        
        if let fontColor = keyValueArray[3].color {
            cell.value2.textColor = UIColor(hexString: fontColor)
        }
        
    }
    
    static func getTopVC() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}

extension Bundle {
    
    private static let bundleID = "tw.com.fpc.FPCDynamicForm"
    
    static var module: Bundle {
        return Bundle(identifier: bundleID) ?? .main
    }
    
}
