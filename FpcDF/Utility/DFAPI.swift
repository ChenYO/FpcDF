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
    
    static func customPost(address: String, parameters: [String: Any], responseCall: @escaping ([String: Any]) -> ()) {
        
        let url = URL(string: address)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        // HTTP Request Parameters which will be sent in HTTP Request Body
        var postString = "";
        
        var isFirst = true
        for (key, value) in parameters {
            
            if isFirst {
                postString += key + "=" + String(describing: value)
                isFirst = false
            }else {
                postString += "&" + key + "=" + String(describing: value)
            }
        }
        
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                
                let dict = convertToDictionary(text: dataString)
                
                if let json = dict {
                    responseCall(json)
                }
            }
        }
        task.resume()
    }
    
    static func customGet(address: String, parameters: [String: Any], responseCall: @escaping ([String: Any]) -> ()) {
        
        var getAddress = address
        var isFirst = true
        
        if !address.contains("?") {
            for (key, value) in parameters {
                if isFirst {
                    getAddress += "?" + key + "=" + String(describing: value)
                    isFirst = false
                }else {
                    getAddress += "&" + key + "=" + String(describing: value)
                }
            }
        }
        
        let url = URL(string: getAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        guard let requestUrl = url else { fatalError() }
        // Create URL Request
        var request = URLRequest(url: requestUrl)
        // Specify HTTP Method to use
        request.httpMethod = "GET"
        
        // Send HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }
            
            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                let dict = convertToDictionary(text: dataString)
                
                if let json = dict {
                    responseCall(json)
                }
            }
            
        }
        task.resume()
    }
    
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
