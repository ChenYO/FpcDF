//
//  API.swift
//  DynamicForm
//
//  Created by 陳仲堯 on 2019/12/19.
//  Copyright © 2019 陳仲堯. All rights reserved.
//

import Foundation
import Alamofire

class DFAPI {
    
    static let fileUploadUrl = "https://mobilefpc.fpcetg.com.tw/commonfile/tempupload"
    
    static func post(address: String, parameters: [String: Any], responseCall: @escaping (DataResponse<Any>, String, [String: Any]) -> ()) {
        

        
        let _parameters = parameters

        Alamofire.request(address, method: .post, parameters: _parameters, encoding: URLEncoding(destination: .httpBody))
            .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                print("Progress: \(progress.fractionCompleted)")
            }
            .validate { request, response, data in
                return .success
            }
            .responseJSON { response in
                
                if let json = response.result.value as? [String: Any] {
                    if let result = json["result"] as? String {
                       
                        responseCall(response, result, json)
                        
                    } else {
                        responseCall(response, "", json)
                    }
                } else {
                    responseCall(response, "", [:])
                }
        }
    }
}
