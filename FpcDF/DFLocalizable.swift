//
//  DFLocalizable.swift
//  FpcDF
//
//  Created by 陳仲堯 on 2020/1/31.
//  Copyright © 2020 陳仲堯. All rights reserved.
//

import Foundation
import UIKit

// Important!! LocalizableKey.swift must sync with Localizable.strins

enum DFLocalizable: String {
    case LOGOUT = "LOGOUT"
    
    case DF_APP_FORCE_UPDATE = "DF_APP_FORCE_UPDATE"
    case DF_APP_UPDATE_TIP = "DF_APP_UPDATE_TIP"
    case DF_APP_FORCE_LOGOUT = "DF_APP_FORCE_LOGOUT"
    

    case DF_COMMAND_CONFIRM = "DF_COMMAND_CONFIRM"
    case DF_COMMAND_CANCEL = "DF_COMMAND_CANCEL"
    case DF_COMMAND_UPDATE_APP = "DF_COMMAND_UPDATE_APP"
    case DF_COMMAND_SKIP = "DF_COMMAND_SKIP"
    
    case DF_SIGN_FAILED = "DF_SIGN_FAILED"
    case DF_CLEAR = "DF_CLEAR"
    case MESSAGE_TIP = "MESSAGE_TIP"
    
    case BACK = "BACK"
    
    
    

    
    case END
    
    static func valueOf(_ key: DFLocalizable) -> String {

        return NSLocalizedString(key.rawValue, bundle: Bundle(for: DynamicForm.self), comment: key.rawValue)
    }
}

